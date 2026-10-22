import Cocoa
import Quartz

final class PreviewViewController: NSViewController, QLPreviewingController {
    // The web page ships once, in the containing app: <App>.app/Contents/PlugIns/<this>.appex -> <App>.app/Contents/Resources/web
    private static let pageURL = Bundle.main.bundleURL
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Resources/web/index.html")

    private lazy var page = MarkdownPage(pageURL: Self.pageURL)

    override func loadView() {
        view = page.webView
        preferredContentSize = NSSize(width: 900, height: 800)
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        // Quick Look puts a double-click recognizer on the view hosting the preview that opens the file in its
        // default app. Double-click should select a word instead, like in any other document.
        var ancestor = view.superview
        while let current = ancestor {
            for case let click as NSClickGestureRecognizer in current.gestureRecognizers where click.numberOfClicksRequired == 2 {
                click.isEnabled = false
            }
            ancestor = current.superview
        }
    }

    func preparePreviewOfFile(at url: URL) async throws {
        try await page.render(url)
    }
}
