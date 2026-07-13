//
//  WzLifeSpriteLoader.swift
//  MapleStoryFile
//
//  Loads stand animations for life sprites - NPCs from Npc.wz and mobs from
//  Mob.wz, which share the same layout:
//    {id:07}.img/stand/{frame}  (canvases with origin/delay)
//  An entry whose `info/link` names another id is an alias for that image.
//

import Foundation

/// A fully loaded life sprite: placement plus its animations.
public struct WzLifeSprite: Sendable {
    public var life: WzMapLife
    public var standFrames: [WzSpriteFrame]
    /// Walking animation (mobs); empty for NPCs.
    public var moveFrames: [WzSpriteFrame]
    public var name: String?
    /// Mob speed modifier percent (`info/speed`, e.g. -50 = half speed).
    public var speedPercent: Int

    public init(life: WzMapLife, standFrames: [WzSpriteFrame], moveFrames: [WzSpriteFrame] = [],
                name: String? = nil, speedPercent: Int = 0) {
        self.life = life
        self.standFrames = standFrames
        self.moveFrames = moveFrames
        self.name = name
        self.speedPercent = speedPercent
    }
}

public final class WzLifeSpriteLoader {

    private let archive: WzArchive
    private var imageCache: [String: [WzNamedProperty]] = [:]

    public init(archive: WzArchive) {
        self.archive = archive
    }

    /// Decode a life sprite's standing animation, following `info/link` aliases.
    public func loadStandFrames(id spriteID: Int) throws -> [WzSpriteFrame] {
        try loadFrames(action: "stand", id: spriteID)
    }

    /// Decode an animation by action name, following `info/link` aliases.
    public func loadFrames(action: String, id spriteID: Int) throws -> [WzSpriteFrame] {
        guard let props = try resolvedProperties(id: spriteID) else { return [] }
        return try decodeFrames(action: action, props: props)
    }

    /// The sprite's `info/speed` percent modifier (0 when absent).
    public func speedPercent(id spriteID: Int) -> Int {
        (try? resolvedProperties(id: spriteID))??.int("info/speed") ?? 0
    }

    /// Image properties with `info/link` aliases resolved.
    private func resolvedProperties(id spriteID: Int) throws -> [WzNamedProperty]? {
        var id = spriteID
        var visited = Set<Int>()
        while visited.insert(id).inserted {
            guard let props = try imageProperties(String(format: "%07d.img", id)) else { return nil }
            if let link = props.string("info/link").flatMap(Int.init), link != id {
                id = link
                continue
            }
            return props
        }
        return nil
    }

    private func decodeFrames(action: String, props: [WzNamedProperty]) throws -> [WzSpriteFrame] {
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
