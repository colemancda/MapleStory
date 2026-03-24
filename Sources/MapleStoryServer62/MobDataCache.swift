//
//  MobDataCache.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// In-memory cache of WZ mob stats, loaded once at server startup.
///
/// Usage:
/// ```swift
/// // At startup:
/// await MobDataCache.shared.load(from: URL(fileURLWithPath: "/path/to/Mob.wz/extracted"))
///
/// // In handlers:
/// let mob = await MobDataCache.shared.mob(id: 100100)
/// ```
public actor MobDataCache {

    public static let shared = MobDataCache()

    private var mobs: [UInt32: WzMob] = [:]

    private init() {}

    /// Load all `*.img.xml` files from a directory (the extracted Mob.wz folder).
    /// Files that fail to parse are skipped with a warning.
    public func load(from directory: URL) {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return }

        var loaded = 0
        for case let url as URL in enumerator {
            guard url.pathExtension == "xml" else { continue }
            do {
                let mob = try WzMob(contentsOf: url)
                mobs[mob.id] = mob
                loaded += 1
            } catch {
                // skip files that don't match the mob format (e.g. string tables)
            }
        }
        print("MobDataCache: loaded \(loaded) mob entries from \(directory.path)")
    }

    /// Look up a mob by ID. Returns nil if not loaded.
    public func mob(id: UInt32) -> WzMob? {
        mobs[id]
    }

    /// Number of loaded mob entries.
    public var count: Int { mobs.count }
}
