//
//  WzMapLoader.swift
//  MapleStoryFile
//
//  Loads a MapleStory map from Map.wz into decoded sprites (RGBA + positions),
//  following the node layout documented by MapleNecrocer:
//    tile: Tile/{tS}.img/{u}/{no}
//    obj:  Obj/{oS}.img/{l0}/{l1}/{l2}
//    back: Back/{bS}.img/back/{no}
//

import Foundation

/// A decoded, positioned map sprite.
public struct WzMapSprite: Sendable {
    public var rgba: [UInt8]
    public var width: Int
    public var height: Int
    public var x: Int
    public var y: Int
    public var originX: Int
    public var originY: Int
    public var z: Int
}

/// A loaded map: its sprites (already decoded to RGBA) and camera bounds.
public struct WzLoadedMap: Sendable {
    public var id: Int
    public var backgrounds: [WzMapSprite]
    public var tiles: [WzMapSprite]
    public var objects: [WzMapSprite]
    public var left: Int
    public var top: Int
    public var right: Int
    public var bottom: Int
}

public final class WzMapLoader {

    private let archive: WzArchive
    private var imageCache: [String: [WzNamedProperty]] = [:]

    public init(archive: WzArchive) {
        self.archive = archive
    }

    /// Load and decode a map by numeric ID (e.g. 100000000 for Henesys).
    public func load(mapID: Int) throws -> WzLoadedMap {
        let group = mapID / 100_000_000
        let imagePath = "Map/Map\(group)/\(String(format: "%09d", mapID)).img"
        guard let props = try imageProperties(imagePath) else {
            throw WzArchiveError.invalidHeader
        }

        var backgrounds: [WzMapSprite] = []
        var tiles: [WzMapSprite] = []
        var objects: [WzMapSprite] = []

        // Backgrounds
        for entry in props["back"]?.children ?? [] {
            guard let bS = entry.value.children.string("bS"), bS.isEmpty == false else { continue }
            let no = entry.value.children.int("no") ?? 0
            let x = entry.value.children.int("x") ?? 0
            let y = entry.value.children.int("y") ?? 0
            let ani = entry.value.children.int("ani") ?? 0
            let folder = ani == 1 ? "ani" : "back"
            if let sprite = try sprite(imagePath: "Back/\(bS).img", inner: "\(folder)/\(no)", x: x, y: y, z: 0) {
                backgrounds.append(sprite)
            }
        }

        // Tiles + objects per layer
        for layer in 0 ... 7 {
            let tileSet = props.string("\(layer)/info/tS")
            if let tileSet, tileSet.isEmpty == false {
                for entry in props.property(at: "\(layer)/tile")?.children ?? [] {
                    let c = entry.value.children
                    guard let u = c.string("u"), let no = c.int("no") else { continue }
                    let x = c.int("x") ?? 0, y = c.int("y") ?? 0, z = c.int("z") ?? 0
                    if let sprite = try sprite(imagePath: "Tile/\(tileSet).img", inner: "\(u)/\(no)", x: x, y: y, z: layer * 100_000 + z) {
                        tiles.append(sprite)
                    }
                }
            }
            for entry in props.property(at: "\(layer)/obj")?.children ?? [] {
                let c = entry.value.children
                guard let oS = c.string("oS"), let l0 = c.string("l0"), let l1 = c.string("l1"), let l2 = c.string("l2") else { continue }
                let x = c.int("x") ?? 0, y = c.int("y") ?? 0, z = c.int("z") ?? 0
                if let sprite = try sprite(imagePath: "Obj/\(oS).img", inner: "\(l0)/\(l1)/\(l2)", x: x, y: y, z: layer * 100_000 + z) {
                    objects.append(sprite)
                }
            }
        }

        tiles.sort { $0.z < $1.z }
        objects.sort { $0.z < $1.z }

        let bounds = computeBounds(props: props, sprites: backgrounds + tiles + objects)
        return WzLoadedMap(id: mapID, backgrounds: backgrounds, tiles: tiles, objects: objects,
                           left: bounds.left, top: bounds.top, right: bounds.right, bottom: bounds.bottom)
    }

    // MARK: - Sprite resolution

    private func sprite(imagePath: String, inner: String, x: Int, y: Int, z: Int) throws -> WzMapSprite? {
        guard let node = try imageProperties(imagePath)?.property(at: inner) else { return nil }
        // Origin comes from the referencing node; pixels may come from a link target.
        let origin = originVector(of: node)
        guard let canvas = try resolveCanvas(node, imagePath: imagePath, depth: 0) else { return nil }
        guard canvas.dataLength > 0 else { return nil }
        let bitmap = try archive.decodeCanvas(canvas)
        return WzMapSprite(rgba: bitmap.rgba, width: bitmap.width, height: bitmap.height,
                           x: x, y: y, originX: origin.x, originY: origin.y, z: z)
    }

    /// Descend to a pixel-bearing canvas, following `_inlink`/`_outlink` and taking
    /// the first frame of an animation.
    private func resolveCanvas(_ node: WzProperty, imagePath: String, depth: Int) throws -> WzCanvas? {
        guard depth < 8 else { return nil }
        if let canvas = node.canvasValue {
            if canvas.dataLength > 0 { return canvas }
            if let inlink = canvas.properties.string("_inlink") {
                if let target = try imageProperties(imagePath)?.property(at: inlink) {
                    return try resolveCanvas(target, imagePath: imagePath, depth: depth + 1)
                }
            }
            if let outlink = canvas.properties.string("_outlink") {
                return try resolveOutlink(outlink, depth: depth + 1)
            }
            return canvas
        }
        // Animation container: use the first frame.
        if let frame = node.children.first(where: { Int($0.name) != nil })?.value {
            return try resolveCanvas(frame, imagePath: imagePath, depth: depth + 1)
        }
        return nil
    }

    private func resolveOutlink(_ outlink: String, depth: Int) throws -> WzCanvas? {
        // e.g. "Map/Tile/woodMarble.img/edD/1" -> strip a leading wz-name component.
        var path = outlink
        if path.hasPrefix("Map/") { path.removeFirst(4) }
        guard let range = path.range(of: ".img/") else { return nil }
        let imagePath = String(path[..<range.upperBound]).dropLast() // include ".img"
        let inner = String(path[range.upperBound...])
        guard let node = try imageProperties(String(imagePath))?.property(at: inner) else { return nil }
        return try resolveCanvas(node, imagePath: String(imagePath), depth: depth)
    }

    private func originVector(of node: WzProperty) -> (x: Int, y: Int) {
        node.canvasValue?.properties.vector("origin") ?? node.children.vector("origin") ?? (0, 0)
    }

    // MARK: - Bounds

    private func computeBounds(props: [WzNamedProperty], sprites: [WzMapSprite]) -> (left: Int, top: Int, right: Int, bottom: Int) {
        if let l = props.int("info/VRLeft"), let t = props.int("info/VRTop"),
           let r = props.int("info/VRRight"), let b = props.int("info/VRBottom") {
            return (l, t, r, b)
        }
        // Fallback: extents of placed sprites.
        var minX = 0, minY = 0, maxX = 0, maxY = 0
        for s in sprites {
            minX = min(minX, s.x - s.originX)
            minY = min(minY, s.y - s.originY)
            maxX = max(maxX, s.x - s.originX + s.width)
            maxY = max(maxY, s.y - s.originY + s.height)
        }
        return (minX, minY, maxX, maxY)
    }

    // MARK: - Image cache

    private func imageProperties(_ path: String) throws -> [WzNamedProperty]? {
        if let cached = imageCache[path] { return cached }
        guard let image = archive.root[path] else { return nil }
        let props = try archive.properties(of: image)
        imageCache[path] = props
        return props
    }
}
