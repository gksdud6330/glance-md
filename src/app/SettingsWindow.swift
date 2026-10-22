import Cocoa

enum QuickLookExtension {
    static let identifier = "io.github.gksdud6330.glancemd.quicklook"

    static var isEnabled: Bool {
        // pluginkit marks an extension the user turned off with a leading "-"; "+" or a blank means it is in use.
        guard let line = run("/usr/bin/pluginkit", "-m", "-i", identifier).output.split(separator: "\n").first else {
            return false
        }
        return !line.hasPrefix("-")
    }

    static func setEnabled(_ enabled: Bool) -> Bool {
        if enabled, let appex = Bundle.main.builtInPlugInsURL?.appendingPathComponent("QuickLookPreview.appex") {
            _ = run("/usr/bin/pluginkit", "-a", appex.path)
        }
        let election = run("/usr/bin/pluginkit", "-e", enabled ? "use" : "ignore", "-i", identifier)
        _ = run("/usr/bin/qlmanage", "-r")
        return election.status == 0
    }

    private static func run(_ tool: String, _ arguments: String...) -> (status: Int32, output: String) {
        let process = Process()
        let pipe = Pipe()
        process.executableURL = URL(fileURLWithPath: tool)
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
        } catch {
            NSLog("GlanceMD: could not run \(tool): \(error)")
            return (-1, "")
        }
        let output = String(decoding: pipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        process.waitUntilExit()
        return (process.terminationStatus, output)
    }
}

@MainActor
final class SettingsWindow: NSObject {
    private let quickLookSwitch = NSSwitch()
    private let copySwitch = NSSwitch()
    private let settingsChanged: () -> Void
    private let openDocument: () -> Void
    private lazy var window = makeWindow()

    init(settingsChanged: @escaping () -> Void, openDocument: @escaping () -> Void) {
        self.settingsChanged = settingsChanged
        self.openDocument = openDocument
        super.init()
    }

    func show() {
        quickLookSwitch.state = QuickLookExtension.isEnabled ? .on : .off
        copySwitch.state = GlanceSettings.load().copyOnSelect ? .on : .off
        if !window.isVisible { window.center() }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func makeWindow() -> NSWindow {
        quickLookSwitch.target = self
        quickLookSwitch.action = #selector(quickLookToggled(_:))
        copySwitch.target = self
        copySwitch.action = #selector(copyToggled(_:))

        let grid = NSGridView(views: [
            [description("Quick Look preview",
                         "Press Space on a Markdown file in Finder to see it rendered. Turn off to get the plain-text preview back."),
             quickLookSwitch],
            [description("Copy selected text automatically",
                         "Selecting text with the mouse in a preview or viewer window copies it to the clipboard."),
             copySwitch],
        ])
        grid.rowSpacing = 20
        grid.columnSpacing = 28
        grid.column(at: 1).xPlacement = .trailing
        for row in 0..<grid.numberOfRows { grid.row(at: row).yPlacement = .center }

        let openButton = NSButton(title: "Open Markdown File…", target: self, action: #selector(openFile(_:)))
        let content = NSStackView(views: [grid, openButton])
        content.orientation = .vertical
        content.alignment = .leading
        content.spacing = 24
        content.translatesAutoresizingMaskIntoConstraints = false

        let container = NSView()
        container.addSubview(content)
        NSLayoutConstraint.activate([
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            content.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
        ])

        let controller = NSViewController()
        controller.view = container
        controller.preferredContentSize = container.fittingSize
        let window = NSWindow(contentViewController: controller)
        window.title = "GlanceMD Settings"
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        return window
    }

    private func description(_ title: String, _ detail: String) -> NSView {
        let titleField = NSTextField(labelWithString: title)
        titleField.font = .systemFont(ofSize: 13, weight: .semibold)
        let detailField = NSTextField(wrappingLabelWithString: detail)
        detailField.font = .systemFont(ofSize: 11)
        detailField.textColor = .secondaryLabelColor
        detailField.widthAnchor.constraint(equalToConstant: 320).isActive = true
        let stack = NSStackView(views: [titleField, detailField])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 3
        return stack
    }

    @objc private func quickLookToggled(_ sender: NSSwitch) {
        let enabled = sender.state == .on
        guard QuickLookExtension.setEnabled(enabled) else {
            sender.state = enabled ? .off : .on
            let alert = NSAlert()
            alert.messageText = "Couldn't change the Quick Look setting"
            alert.informativeText = "Turn GlanceMD Quick Look on or off in System Settings → General → Login Items & Extensions → Quick Look."
            alert.runModal()
            return
        }
    }

    @objc private func copyToggled(_ sender: NSSwitch) {
        var settings = GlanceSettings.load()
        settings.copyOnSelect = sender.state == .on
        do {
            try settings.save()
            settingsChanged()
        } catch {
            sender.state = settings.copyOnSelect ? .off : .on
            NSAlert(error: error).runModal()
        }
    }

    @objc private func openFile(_ sender: Any?) {
        openDocument()
    }
}
