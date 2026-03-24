//
//  MapDataCache.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// In-memory cache of WZ map data, loaded once at server startup.
///
/// Usage:
/// ```swift
/// await MapDataCache.shared.load(from: URL(fileURLWithPath: "/path/to/Map.wz/extracted/Map"))
/// let wzMap = await MapDataCache.shared.map(id: 100000000)
/// ```
public actor MapDataCache {

    public static let shared = MapDataCache()

    private var maps: [UInt32: WzMap] = [:]

    private init() {}

    /// Load all `*.img.xml` files from the Map.wz/Map directory tree.
    /// Subdirectories (Map0, Map1, … Map9) are traversed automatically.
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
                let wzMap = try WzMap(contentsOf: url)
                maps[wzMap.id] = wzMap
                loaded += 1
            } catch {
                // skip non-map files (area info, etc.)
            }
        }
        print("MapDataCache: loaded \(loaded) map entries from \(directory.path)")
    }

    /// Look up a map by ID. Returns nil if not loaded.
    public func map(id: Map.ID) -> WzMap? {
        maps[id.rawValue]
    }

    public var count: Int { maps.count }
}
