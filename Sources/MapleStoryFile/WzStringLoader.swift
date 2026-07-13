//
//  WzStringLoader.swift
//  MapleStoryFile
//
//  Looks up display names from String.wz:
//    Npc.img/{id}/name, Mob.img/{id}/name, Map.img/{region}/{id}/mapName
//

import Foundation

public final class WzStringLoader {

    private let archive: WzArchive
    private var imageCache: [String: [WzNamedProperty]] = [:]

    public init(archive: WzArchive) {
        self.archive = archive
    }

    /// The display name of an NPC (e.g. 1012000 = "Regular Cab").
    public func npcName(id: Int) -> String? {
        name(image: "Npc.img", id: id)
    }

    /// The display name of a mob (e.g. 100101 = "Blue Snail").
    public func mobName(id: Int) -> String? {
        name(image: "Mob.img", id: id)
    }

    private func name(image: String, id: Int) -> String? {
        guard let props = try? imageProperties(image) else { return nil }
        return props.string("\(id)/name")
    }

    private func imageProperties(_ path: String) throws -> [WzNamedProperty]? {
        if let cached = imageCache[path] { return cached }
        guard let image = archive.root[path] else { return nil }
        let props = try archive.properties(of: image)
        imageCache[path] = props
        return props
    }
}
