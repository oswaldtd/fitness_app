import Foundation

enum SeedGuard {
    private static let key = "seedDataVersion"
    static let currentVersion = 1

    static var needsSeed: Bool {
        UserDefaults.standard.integer(forKey: key) < currentVersion
    }

    static func markSeeded() {
        UserDefaults.standard.set(currentVersion, forKey: key)
    }

    /// Call from Settings debug menu to re-seed after a plan update
    static func resetForDebug() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
