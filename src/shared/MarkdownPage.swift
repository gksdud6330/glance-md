import Cocoa
import WebKit

enum MarkdownFile {
    static let extensions: Set<String> = ["md", "markdown", "mdown", "mdwn", "mkd", "mkdn", "mkdown"]
}

@MainActor
private final class SelectionCopier: NSObject, WKScriptMessageHandler {
    static let messageName = "copySelection"

    func userContentController(_ controller: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let text = message.body as? String, !text.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
    }
}

@MainActor
final class MarkdownPage: NSObject, WKNavigationDelegate {
    let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
    var openMarkdownLink: (URL) -> Void = { NSWorkspace.shared.open($0) }

    private enum PageState {
        case loading, ready, failed(Error)
    }

    private let pageURL: URL
    private var pageNavigation: WKNavigation?
    private var pageState = PageState.loading
    private var pageWaiters: [CheckedContinuation<Void, Error>] = []
    private var lastFileURL: URL?

    init(pageURL: URL) {
        self.pageURL = pageURL
        super.init()
        webView.allowsMagnification = true
        webView.navigationDelegate = self
        webView.configuration.userContentController.add(SelectionCopier(), name: SelectionCopier.messageName)
        loadPage()
    }

    func render(_ fileURL: URL) async throws {
        lastFileURL = fileURL
        try await pageLoaded()
        let markdown: String
        do {
            markdown = String(decoding: try Data(contentsOf: fileURL), as: UTF8.self)
        } catch {
            markdown = "> 파일을 읽을 수 없습니다: `\(fileURL.path)`\n>\n> \(error.localizedDescription)"
        }
        _ = try await webView.callAsyncJavaScript(
            "window.glancemd.setCopyOnSelect(copyOnSelect); return await window.glancemd.render(markdown, baseURL)",
            arguments: ["markdown": markdown, "baseURL": fileURL.deletingLastPathComponent().absoluteString,
                        "copyOnSelect": GlanceSettings.load().copyOnSelect],
            contentWorld: .page)
    }

    private func loadPage() {
        pageState = .loading
        // Read access to "/" lets relative images anywhere load; the page itself never runs document script.
        pageNavigation = webView.loadFileURL(pageURL, allowingReadAccessTo: URL(fileURLWithPath: "/"))
    }

    private func pageLoaded() async throws {
        switch pageState {
        case .ready: return
        case .failed(let error): throw error
        case .loading: try await withCheckedThrowingContinuation { pageWaiters.append($0) }
        }
    }

    private func finishPageLoad(_ navigation: WKNavigation!, _ result: Result<Void, Error>) {
        guard navigation === pageNavigation else { return }
        switch result {
        case .success: pageState = .ready
        case .failure(let error): pageState = .failed(error)
        }
        let waiters = pageWaiters
        pageWaiters = []
        waiters.forEach { $0.resume(with: result) }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        finishPageLoad(navigation, .success(()))
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        finishPageLoad(navigation, .failure(error))
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        finishPageLoad(navigation, .failure(error))
    }

    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        loadPage()
        guard let lastFileURL else { return }
        Task {
            do {
                try await render(lastFileURL)
            } catch {
                NSLog("Markdown re-render after web process crash failed: \(error)")
            }
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping @MainActor (WKNavigationActionPolicy) -> Void) {
        guard let target = action.request.url else { return decisionHandler(.cancel) }
        let isViewerPageOrInPageAnchor = target.isFileURL && target.path == pageURL.path
        if isViewerPageOrInPageAnchor { return decisionHandler(.allow) }
        decisionHandler(.cancel)
        if target.isFileURL {
            if MarkdownFile.extensions.contains(target.pathExtension.lowercased()) {
                openMarkdownLink(target)
            } else {
                // Never launch arbitrary local files from a document link; just show them in Finder.
                NSWorkspace.shared.activateFileViewerSelecting([target])
            }
        } else if ["http", "https", "mailto"].contains(target.scheme?.lowercased() ?? "") {
            NSWorkspace.shared.open(target)
        }
    }
}
