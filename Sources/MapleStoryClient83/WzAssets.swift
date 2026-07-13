//
//  WzAssets.swift
//  MapleStoryClient83
//
//  Opens WZ archives out of a game directory (e.g. the MapleStory install
//  folder containing Map.wz, Character.wz, ...), loading and caching each file
//  on first use.
//

import Foundation
import MapleStoryFile

/// A directory of `.wz` files, loaded lazily by name.
final class WzAssets {

    let directory: URL
    let version: WzMapleVersion
    private var cache: [String: WzArchive] = [:]

    init(directory: String, region: String) {
        self.directory = URL(fileURLWithPath: directory, isDirectory: true)
        switch region.lowercased() {
        case "ems": self.version = .ems
        case "bms": self.version = .bms
        default: self.version = .gms
        }
    }

    /// The archive for `name` (e.g. "Map"), or nil when the file doesn't exist.
    func archive(_ name: String) throws -> WzArchive? {
        if let cached = cache[name] { return cached }
        let url = directory.appendingPathComponent("\(name).wz")
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("\(name).wz not found in \(directory.path), skipping")
            return nil
        }
        print("Loading \(url.path) ...")
        let archive = try WzArchive(data: try Data(contentsOf: url), mapleVersion: version)
        cache[name] = archive
        return archive
    }

    /// The archive for `name`, throwing when the file is missing.
    func requireArchive(_ name: String) throws -> WzArchive {
        guard let archive = try archive(name) else {
            throw WzAssetsError.missingFile("\(name).wz", directory.path)
        }
        return archive
    }
}

enum WzAssetsError: Error, CustomStringConvertible {
    case missingFile(String, String)

    var description: String {
        switch self {
        case let .missingFile(name, directory):
            return "\(name) not found in \(directory)"
        }
    }
}
