import Cocoa
import UniformTypeIdentifiers
import WebKit

enum AppBundle {
    static let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "GlanceMD"
    static let pageURL: URL = {
        guard let url = Bundle.main.url(forResource: "index", withExtension: "html", subdirectory: "web") else {
            fatalError("web/index.html missing from the app bundle")
        }
        return url
    }()
}

@MainActor
final class DocumentWindow: NSObject, NSWindowDelegate {
    let fileURL: URL
    let window: NSWindow
    let page: MarkdownPage
    private weak var app: AppDelegate?
    private var watcher: DispatchSourceFileSystemObject?

    init(fileURL: URL, app: AppDelegate) {
        self.fileURL = fileURL
        self.app = app
        page = MarkdownPage(pageURL: AppBundle.pageURL)
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 920, height: 780),
                          styleMask: [.titled, .closable, .miniaturizable, .resizable],
                          backing: .buffered, defer: false)
        super.init()

        page.openMarkdownLink = { [weak app] url in app?.open(url) }
        window.isReleasedWhenClosed = false
        window.title = fileURL.lastPathComponent
        window.representedURL = fileURL
        window.tabbingIdentifier = "\(AppBundle.name).document"
        window.tabbingMode = .preferred
        window.contentView = page.webView
        window.delegate = self

        render()
        startWatching()
    }

    func render() {
        Task {
            do {
                try await page.render(fileURL)
            } catch {
                NSLog("Rendering \(fileURL.path) failed: \(error)")
            }
        }
    }

    private func startWatching() {
        watcher?.cancel()
        let fd = open(fileURL.path, O_EVTONLY)
        guard fd >= 0 else { return }
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd, eventMask: [.write, .extend, .delete, .rename], queue: .main)
        source.setEventHandler { [weak self, weak source] in
            guard let self, let source else { return }
            if source.data.contains(.delete) || source.data.contains(.rename) {
                // Editors save atomically (write temp file, rename over); re-attach once the new file exists.
                self.reattachWatcher(attemptsLeft: 20)
            } else {
                self.render()
            }
        }
        source.setCancelHandler { close(fd) }
        source.resume()
        watcher = source
    }

    private func reattachWatcher(attemptsLeft: Int) {
        watcher?.cancel()
        watcher = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self, self.window.isVisible else { return }
            if FileManager.default.fileExists(atPath: self.fileURL.path) {
                self.startWatching()
                self.render()
            } else if attemptsLeft > 0 {
                self.reattachWatcher(attemptsLeft: attemptsLeft - 1)
            }
        }
    }

    func windowWillClose(_ notification: Notification) {
        watcher?.cancel()
        watcher = nil
        app?.documentClosed(self)
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var documents: [DocumentWindow] = []
    private lazy var settingsWindow = SettingsWindow(
        settingsChanged: { [weak self] in self?.documents.forEach { $0.render() } },
        openDocument: { [weak self] in self?.openDocument(nil) })

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.mainMenu = buildMainMenu()
        let launchedWithoutDocuments = notification.userInfo?[NSApplication.launchIsDefaultUserInfoKey] as? Bool ?? true
        guard launchedWithoutDocuments else { return }
        DispatchQueue.main.async {
            if self.documents.isEmpty { self.showSettings(nil) }
        }
    }

    func application(_ application: NSApplication, open urls: [URL]) {
        urls.forEach(open)
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag { showSettings(nil) }
        return true
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }

    func open(_ url: URL) {
        let fileURL = url.standardizedFileURL.resolvingSymlinksInPath()
        if let existing = documents.first(where: { $0.fileURL == fileURL }) {
            existing.window.makeKeyAndOrderFront(nil)
            return
        }
        let document = DocumentWindow(fileURL: fileURL, app: self)
        let host = NSApp.keyWindow ?? documents.last?.window
        documents.append(document)
        if let host, host.isVisible, host.tabbingIdentifier == document.window.tabbingIdentifier {
            host.addTabbedWindow(document.window, ordered: .above)
        } else {
            document.window.center()
        }
        document.window.makeKeyAndOrderFront(nil)
        NSDocumentController.shared.noteNewRecentDocumentURL(fileURL)
    }

    func documentClosed(_ document: DocumentWindow) {
        documents.removeAll { $0 === document }
    }

    private var activeDocument: DocumentWindow? {
        documents.first { $0.window === NSApp.keyWindow }
    }

    @objc func openDocument(_ sender: Any?) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [UTType("net.daringfireball.markdown"), .plainText].compactMap { $0 }
        NSApp.activate(ignoringOtherApps: true)
        guard panel.runModal() == .OK else { return }
        panel.urls.forEach(open)
    }

    @objc func showSettings(_ sender: Any?) { settingsWindow.show() }

    @objc func reloadDocument(_ sender: Any?) { activeDocument?.render() }

    @objc func zoomIn(_ sender: Any?) { setZoom { min($0 * 1.1, 3) } }
    @objc func zoomOut(_ sender: Any?) { setZoom { max($0 / 1.1, 0.5) } }
    @objc func actualSize(_ sender: Any?) { setZoom { _ in 1 } }

    private func setZoom(_ next: (CGFloat) -> CGFloat) {
        guard let webView = activeDocument?.page.webView else { return }
        webView.pageZoom = next(webView.pageZoom)
    }

    private func buildMainMenu() -> NSMenu {
        let main = NSMenu()
        func submenu(_ title: String, _ items: [NSMenuItem]) -> NSMenu {
            let menu = NSMenu(title: title)
            items.forEach(menu.addItem)
            let holder = NSMenuItem()
            holder.submenu = menu
            main.addItem(holder)
            return menu
        }
        func item(_ title: String, _ action: Selector, _ key: String,
                  _ modifiers: NSEvent.ModifierFlags = .command, target: AnyObject? = nil) -> NSMenuItem {
            let menuItem = NSMenuItem(title: title, action: action, keyEquivalent: key)
            menuItem.keyEquivalentModifierMask = modifiers
            menuItem.target = target
            return menuItem
        }

        _ = submenu(AppBundle.name, [
            item("About \(AppBundle.name)", #selector(NSApplication.orderFrontStandardAboutPanel(_:)), ""),
            .separator(),
            item("Settings…", #selector(showSettings(_:)), ",", target: self),
            .separator(),
            item("Hide \(AppBundle.name)", #selector(NSApplication.hide(_:)), "h"),
            item("Quit \(AppBundle.name)", #selector(NSApplication.terminate(_:)), "q"),
        ])
        _ = submenu("File", [
            item("Open…", #selector(openDocument(_:)), "o", target: self),
            item("Reload", #selector(reloadDocument(_:)), "r", target: self),
            .separator(),
            item("Close", #selector(NSWindow.performClose(_:)), "w"),
        ])
        _ = submenu("Edit", [
            item("Copy", #selector(NSText.copy(_:)), "c"),
            item("Select All", #selector(NSText.selectAll(_:)), "a"),
        ])
        let zoomInAlias = item("Zoom In", #selector(zoomIn(_:)), "=", target: self)
        zoomInAlias.isHidden = true
        zoomInAlias.allowsKeyEquivalentWhenHidden = true
        _ = submenu("View", [
            item("Zoom In", #selector(zoomIn(_:)), "+", target: self),
            zoomInAlias,
            item("Zoom Out", #selector(zoomOut(_:)), "-", target: self),
            item("Actual Size", #selector(actualSize(_:)), "0", target: self),
        ])
        let windowMenu = submenu("Window", [
            item("Minimize", #selector(NSWindow.performMiniaturize(_:)), "m"),
            item("Zoom", #selector(NSWindow.performZoom(_:)), ""),
            .separator(),
            item("Show Previous Tab", #selector(NSWindow.selectPreviousTab(_:)), "[", [.command, .shift]),
            item("Show Next Tab", #selector(NSWindow.selectNextTab(_:)), "]", [.command, .shift]),
            item("Merge All Windows", #selector(NSWindow.mergeAllWindows(_:)), ""),
        ])
        NSApp.windowsMenu = windowMenu
        return main
    }
}

let delegate = MainActor.assumeIsolated { AppDelegate() }
NSApplication.shared.delegate = delegate
NSApplication.shared.setActivationPolicy(.regular)
NSApplication.shared.run()
