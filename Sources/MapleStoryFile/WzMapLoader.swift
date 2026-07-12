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

/// A decoded background/foreground layer, carrying the parallax + tiling
/// parameters needed to reproduce MapleStory's scrolling backdrops.
///
/// Positioning follows the reference client's `Background::draw`: the layer's
/// screen position is `base position + rx/ry-scaled parallax offset` (already in
/// screen space, not world space), then wrapped for tiling.
public struct WzMapBackground: Sendable {
    public var rgba: [UInt8]
    public var width: Int
    public var height: Int
    /// Base position (the WZ `x`/`y` fields).
    public var x: Int
    public var y: Int
    public var originX: Int
    public var originY: Int
    /// Parallax rate, percent. 100 = scrolls with the world; 0 = fixed to the screen.
    public var rx: Int
    public var ry: Int
    /// Tile spacing; falls back to the bitmap's own size when zero.
    public var cx: Int
    public var cy: Int
    public var horizontalTile: Bool
    public var verticalTile: Bool
    public var isForeground: Bool
    public var opacity: Float
    public var flipped: Bool
}

/// A foothold segment: a piece of walkable ground (or a vertical wall) from the
/// map's `foothold/{layer}/{group}/{id}` tree.
public struct WzFoothold: Sendable {
    public var id: Int
    public var layer: Int
    public var x1: Int
    public var y1: Int
    public var x2: Int
    public var y2: Int
    public var previousID: Int
    public var nextID: Int

    /// Vertical segments are walls, not walkable ground.
    public var isWall: Bool { x1 == x2 }

    /// The segment's interpolated y at horizontal position `x`, if `x` is within
    /// its span (walls excluded).
    public func groundY(atX x: Float) -> Float? {
        guard isWall == false else { return nil }
        let minX = Float(min(x1, x2))
        let maxX = Float(max(x1, x2))
        guard x >= minX, x <= maxX else { return nil }
        let t = (x - Float(x1)) / Float(x2 - x1)
        return Float(y1) + t * Float(y2 - y1)
    }
}

/// A loaded map: its sprites (already decoded to RGBA) and camera bounds.
public struct WzLoadedMap: Sendable {
    public var id: Int
    public var backgrounds: [WzMapBackground]
    public var foregrounds: [WzMapBackground]
    public var tiles: [WzMapSprite]
    public var objects: [WzMapSprite]
    public var left: Int
    public var top: Int
    public var right: Int
    public var bottom: Int
    /// The map's default spawn point (its first portal, conventionally "sp"), or
    /// the map's horizontal center at the bottom of its bounds if no portal exists.
    public var spawnX: Int
    public var spawnY: Int
    /// Walkable ground / wall geometry.
    public var footholds: [WzFoothold]
}

public extension WzLoadedMap {

    /// The y of the nearest walkable foothold at `x` lying at or below `y`
    /// (allowing `tolerance` above it, for climbing slopes), or `nil` when there
    /// is no ground under that point.
    func groundY(atX x: Float, below y: Float, tolerance: Float = 0) -> Float? {
        var best: Float?
        for foothold in footholds {
            guard let groundY = foothold.groundY(atX: x), groundY >= y - tolerance else { continue }
            if let current = best {
                if groundY < current { best = groundY }
            } else {
                best = groundY
            }
        }
        return best
    }
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

        var backgrounds: [WzMapBackground] = []
        var foregrounds: [WzMapBackground] = []
        var tiles: [WzMapSprite] = []
        var objects: [WzMapSprite] = []

        // Backgrounds
        for entry in props["back"]?.children ?? [] {
            let c = entry.value.children
            guard let bS = c.string("bS"), bS.isEmpty == false else { continue }
            let no = c.int("no") ?? 0
            let x = c.int("x") ?? 0
            let y = c.int("y") ?? 0
            let ani = c.int("ani") ?? 0
            let folder = ani == 1 ? "ani" : "back"
            guard let decoded = try decodeSprite(imagePath: "Back/\(bS).img", inner: "\(folder)/\(no)") else { continue }

            let type = c.int("type") ?? 0
            let horizontalTile = [1, 3, 4, 6, 7].contains(type)
            let verticalTile = [2, 3, 5, 6, 7].contains(type)
            let alpha = c.int("a") ?? 255
            let background = WzMapBackground(
                rgba: decoded.rgba, width: decoded.width, height: decoded.height,
                x: x, y: y, originX: decoded.originX, originY: decoded.originY,
                rx: c.int("rx") ?? 0, ry: c.int("ry") ?? 0,
                cx: c.int("cx") ?? 0, cy: c.int("cy") ?? 0,
                horizontalTile: horizontalTile, verticalTile: verticalTile,
                isForeground: (c.int("front") ?? 0) != 0,
                opacity: Float(alpha) / 255,
                flipped: (c.int("f") ?? 0) != 0
            )
            if background.isForeground {
                foregrounds.append(background)
            } else {
                backgrounds.append(background)
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

        // Footholds: foothold/{layer}/{group}/{id}
        var footholds: [WzFoothold] = []
        for layerEntry in props["foothold"]?.children ?? [] {
            let layer = Int(layerEntry.name) ?? 0
            for groupEntry in layerEntry.value.children {
                for segmentEntry in groupEntry.value.children {
                    let c = segmentEntry.value.children
                    guard let x1 = c.int("x1"), let y1 = c.int("y1"),
                          let x2 = c.int("x2"), let y2 = c.int("y2") else { continue }
                    footholds.append(WzFoothold(
                        id: Int(segmentEntry.name) ?? 0, layer: layer,
                        x1: x1, y1: y1, x2: x2, y2: y2,
                        previousID: c.int("prev") ?? 0, nextID: c.int("next") ?? 0
                    ))
                }
            }
        }

        let bounds = computeBounds(props: props, tiles: tiles, objects: objects)
        let spawn = props.property(at: "portal/0")?.children
        let spawnX = spawn?.int("x") ?? (bounds.left + bounds.right) / 2
        let spawnY = spawn?.int("y") ?? bounds.bottom

        return WzLoadedMap(id: mapID, backgrounds: backgrounds, foregrounds: foregrounds,
                           tiles: tiles, objects: objects,
                           left: bounds.left, top: bounds.top, right: bounds.right, bottom: bounds.bottom,
                           spawnX: spawnX, spawnY: spawnY, footholds: footholds)
    }

    // MARK: - Sprite resolution

    private struct DecodedSprite {
        var rgba: [UInt8]
        var width: Int
        var height: Int
        var originX: Int
        var originY: Int
    }

    private func sprite(imagePath: String, inner: String, x: Int, y: Int, z: Int) throws -> WzMapSprite? {
        guard let decoded = try decodeSprite(imagePath: imagePath, inner: inner) else { return nil }
        return WzMapSprite(rgba: decoded.rgba, width: decoded.width, height: decoded.height,
                           x: x, y: y, originX: decoded.originX, originY: decoded.originY, z: z)
    }

    private func decodeSprite(imagePath: String, inner: String) throws -> DecodedSprite? {
        guard let node = try imageProperties(imagePath)?.property(at: inner) else { return nil }
        // The presentation canvas (frame 0 of an animation) owns the origin/anchor
        // data - even when its pixels are delegated elsewhere via _inlink/_outlink.
        guard let presentation = presentationCanvas(of: node, depth: 0) else { return nil }
        let origin = presentation.properties.vector("origin") ?? (0, 0)
        guard let pixels = try pixelCanvas(for: presentation, imagePath: imagePath, depth: 0),
              pixels.dataLength > 0 else { return nil }
        let bitmap = try archive.decodeCanvas(pixels)
        return DecodedSprite(rgba: bitmap.rgba, width: bitmap.width, height: bitmap.height,
                             originX: origin.x, originY: origin.y)
    }

    /// Descend containers (animations) to the first canvas, without following links.
    private func presentationCanvas(of node: WzProperty, depth: Int) -> WzCanvas? {
        guard depth < 8 else { return nil }
        if let canvas = node.canvasValue { return canvas }
        if let frame = node.children.first(where: { Int($0.name) != nil })?.value {
            return presentationCanvas(of: frame, depth: depth + 1)
        }
        return nil
    }

    /// The canvas actually holding pixel data: the presentation canvas itself, or
    /// the `_inlink`/`_outlink` target it delegates its bitmap to.
    private func pixelCanvas(for canvas: WzCanvas, imagePath: String, depth: Int) throws -> WzCanvas? {
        guard depth < 8 else { return nil }
        if canvas.dataLength > 0 { return canvas }
        if let inlink = canvas.properties.string("_inlink"),
           let target = try imageProperties(imagePath)?.property(at: inlink),
           let targetCanvas = presentationCanvas(of: target, depth: 0) {
            return try pixelCanvas(for: targetCanvas, imagePath: imagePath, depth: depth + 1)
        }
        if let outlink = canvas.properties.string("_outlink") {
            // e.g. "Map/Tile/woodMarble.img/edD/1" -> strip the leading wz name.
            var path = outlink
            if path.hasPrefix("Map/") { path.removeFirst(4) }
            guard let range = path.range(of: ".img/") else { return nil }
            let targetImage = String(String(path[..<range.upperBound]).dropLast()) // include ".img"
            let inner = String(path[range.upperBound...])
            guard let node = try imageProperties(targetImage)?.property(at: inner),
                  let targetCanvas = presentationCanvas(of: node, depth: 0) else { return nil }
            return try pixelCanvas(for: targetCanvas, imagePath: targetImage, depth: depth + 1)
        }
        return canvas
    }

    // MARK: - Bounds

    private func computeBounds(props: [WzNamedProperty], tiles: [WzMapSprite], objects: [WzMapSprite]) -> (left: Int, top: Int, right: Int, bottom: Int) {
        if let l = props.int("info/VRLeft"), let t = props.int("info/VRTop"),
           let r = props.int("info/VRRight"), let b = props.int("info/VRBottom") {
            return (l, t, r, b)
        }
        // Fallback: extents of placed tiles/objects (backgrounds are screen-relative,
        // not world-placed, so they don't inform world bounds).
        var minX = 0, minY = 0, maxX = 0, maxY = 0
        for s in tiles + objects {
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
