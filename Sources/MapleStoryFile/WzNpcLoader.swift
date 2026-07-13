//
//  WzNpcLoader.swift
//  MapleStoryFile
//
//  Loads NPC stand animations from Npc.wz:
//    Npc/{id:07}.img/stand/{frame}  (canvases with origin/z/delay)
//  An NPC whose `info/link` names another id is an alias for that NPC's image.
//

import Foundation

public final class WzNpcLoader {

    private let archive: WzArchive
    private var imageCache: [String: [WzNamedProperty]] = [:]

    public init(archive: WzArchive) {
        self.archive = archive
    }

    /// Decode an NPC's standing animation, following `info/link` aliases.
    public func loadStandFrames(npcID: Int) throws -> [WzSpriteFrame] {
        var id = npcID
        var visited = Set<Int>()
        while visited.insert(id).inserted {
            guard let props = try imageProperties(String(format: "%07d.img", id)) else { return [] }
            if let link = props.string("info/link").flatMap(Int.init), link != id {
                id = link
                continue
            }
            return try decodeFrames(action: "stand", props: props, imagePath: String(format: "%07d.img", id))
        }
        return []
    }

    private func decodeFrames(action: String, props: [WzNamedProperty], imagePath: String) throws -> [WzSpriteFrame] {
        guard let container = props[action]?.children else { return [] }
        let indices = container.map(\.name).compactMap(Int.init).sorted()
        var frames: [WzSpriteFrame] = []
        frames.reserveCapacity(indices.count)
        for index in indices {
            guard let node = container["\(index)"],
                  var canvas = node.canvasValue else { continue }
            let origin = canvas.properties.vector("origin") ?? (0, 0)
            let delay = canvas.properties.int("delay") ?? 100
            // Frames may delegate pixels within the same image via _inlink.
            if canvas.dataLength == 0, let inlink = canvas.properties.string("_inlink"),
               let target = props.property(at: inlink)?.canvasValue {
                canvas = target
            }
            guard canvas.dataLength > 0,
                  let bitmap = try? archive.decodeCanvas(canvas) else { continue }
            frames.append(WzSpriteFrame(rgba: bitmap.rgba, width: bitmap.width, height: bitmap.height,
                                        originX: origin.x, originY: origin.y,
                                        delayMilliseconds: max(delay, 1)))
        }
        return frames
    }

    private func imageProperties(_ path: String) throws -> [WzNamedProperty]? {
        if let cached = imageCache[path] { return cached }
        guard let image = archive.root[path] else { return nil }
        let props = try archive.properties(of: image)
        imageCache[path] = props
        return props
    }
}
