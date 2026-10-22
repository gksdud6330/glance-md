import Foundation

struct GlanceSettings: Codable, Equatable {
    var copyOnSelect = false

    init() {}

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        copyOnSelect = try values.decodeIfPresent(Bool.self, forKey: .copyOnSelect) ?? false
    }

    // The sandboxed Quick Look extension sees its container as home, so the file is addressed from the real home,
    // which the extension can read through its read-only file exception.
    static let fileURL: URL = {
        let home = getpwuid(getuid()).map { String(cString: $0.pointee.pw_dir) } ?? NSHomeDirectory()
        return URL(fileURLWithPath: home, isDirectory: true)
            .appendingPathComponent("Library/Application Support/GlanceMD/settings.json")
    }()

    static func load() -> GlanceSettings {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return GlanceSettings() }
        do {
            return try JSONDecoder().decode(GlanceSettings.self, from: Data(contentsOf: fileURL))
        } catch {
            NSLog("GlanceMD: using default settings, could not read \(fileURL.path): \(error)")
            return GlanceSettings()
        }
    }

    func save() throws {
        try FileManager.default.createDirectory(
            at: Self.fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(self).write(to: Self.fileURL, options: .atomic)
    }
}
