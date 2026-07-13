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

/// One frame of a (possibly animated) map sprite. Each frame carries its own
/// bitmap, origin, and hold duration.
public struct WzSpriteFrame: Sendable {
    public var rgba: [UInt8]
    public var width: Int
    public var height: Int
    public var originX: Int
    public var originY: Int
    public var delayMilliseconds: Int
}

/// A decoded, positioned map sprite. The top-level bitmap fields mirror
/// `frames[0]`; animated objects carry every frame in `frames`.
public struct WzMapSprite: Sendable {
    public var rgba: [UInt8]
    public var width: Int
    public var height: Int
    public var x: Int
    public var y: Int
    public var originX: Int
    public var originY: Int
    /// Map layer (0...7). Layers draw in order; within a layer objects draw
    /// before tiles (the reference client's `TilesObjs::draw`).
    public var layer: Int
    /// Z within the layer: objects use their placement `z`; tiles use the
    /// tileset canvas's `z` (falling back to `zM` when zero).
    public var z: Int
    /// Horizontal mirror (the placement's `f` flag).
    public var flipped: Bool
    /// All animation frames (a single entry for static sprites).
    public var frames: [WzSpriteFrame]

    public init(rgba: [UInt8], width: Int, height: Int, x: Int, y: Int,
                originX: Int, originY: Int, layer: Int, z: Int, flipped: Bool,
                frames: [WzSpriteFrame]) {
        self.rgba = rgba
        self.width = width
        self.height = height
        self.x = x
        self.y = y
        self.originX = originX
        self.originY = originY
        self.layer = layer
        self.z = z
        self.flipped = flipped
        self.frames = frames
    }
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
    /// NPC / mob placements from the map's `life` node.
    public var life: [WzMapLife]
    /// Portals (spawn points, map transitions).
    public var portals: [WzMapPortal]
}

/// A portal from the map's `portal` node.
public struct WzMapPortal: Sendable {
    /// Portal name (`pn`), e.g. "sp", "east00".
    public var name: String
    /// Portal type (`pt`): 0 = spawn point, 1 = invisible, 2 = visible, ...
    public var type: Int
    public var x: Int
    public var y: Int
    /// Target map id (`tm`); 999999999 means none.
    public var targetMap: Int
    /// Target portal name in the target map (`tn`).
    public var targetName: String

    /// Whether this portal transports somewhere.
    public var isUsable: Bool {
        targetMap != 999_999_999 && targetMap >= 0 && type != 0
    }

    /// Whether the client draws the portal swirl for it.
    public var isVisible: Bool { type == 2 }
}

/// An NPC or mob placement from the map's `life` node.
public struct WzMapLife: Sendable {
    /// "n" = NPC, "m" = mob.
    public var type: String
    public var id: Int
    public var x: Int
    /// The foothold-snapped foot y (the `cy` field).
    public var y: Int
    /// The foothold this life stands on (its layer decides draw order).
    public var footholdID: Int
    public var flipped: Bool
    public var hidden: Bool
}

public extension WzLoadedMap {

    /// The nearest walkable foothold at `x` lying at or below `y` (allowing
    /// `tolerance` above it, for climbing slopes), with its interpolated y, or
    /// `nil` when there is no ground under that point.
    func ground(atX x: Float, below y: Float, tolerance: Float = 0) -> (y: Float, foothold: WzFoothold)? {
        var best: (y: Float, foothold: WzFoothold)?
        for foothold in footholds {
            guard let groundY = foothold.groundY(atX: x), groundY >= y - tolerance else { continue }
            if let current = best {
                if groundY < current.y { best = (groundY, foothold) }
            } else {
                best = (groundY, foothold)
            }
        }
        return best
    }

    /// The y of the nearest walkable foothold at `x` lying at or below `y`.
    func groundY(atX x: Float, below y: Float, tolerance: Float = 0) -> Float? {
        ground(atX: x, below: y, tolerance: tolerance)?.y
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
                    let x = c.int("x") ?? 0, y = c.int("y") ?? 0
                    // Tile z lives on the tileset canvas, not the placement.
                    if let sprite = try sprite(imagePath: "Tile/\(tileSet).img", inner: "\(u)/\(no)",
                                               x: x, y: y, layer: layer, z: nil, flipped: false) {
                        tiles.append(sprite)
                    }
                }
            }
            for entry in props.property(at: "\(layer)/obj")?.children ?? [] {
                let c = entry.value.children
                guard let oS = c.string("oS"), let l0 = c.string("l0"), let l1 = c.string("l1"), let l2 = c.string("l2") else { continue }
                let x = c.int("x") ?? 0, y = c.int("y") ?? 0, z = c.int("z") ?? 0
                let flipped = (c.int("f") ?? 0) != 0
                if let sprite = try sprite(imagePath: "Obj/\(oS).img", inner: "\(l0)/\(l1)/\(l2)",
                                           x: x, y: y, layer: layer, z: z, flipped: flipped) {
                    objects.append(sprite)
                }
            }
        }

        // Stable sort by (layer, z) so equal-z sprites keep file order.
        tiles = tiles.enumerated()
            .sorted { ($0.element.layer, $0.element.z, $0.offset) < ($1.element.layer, $1.element.z, $1.offset) }
            .map(\.element)
        objects = objects.enumerated()
            .sorted { ($0.element.layer, $0.element.z, $0.offset) < ($1.element.layer, $1.element.z, $1.offset) }
            .map(\.element)

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

        // Life (NPCs / mobs)
        var life: [WzMapLife] = []
        for entry in props["life"]?.children ?? [] {
            let c = entry.value.children
            guard let type = c.string("type"),
                  let id = c.string("id").flatMap(Int.init) else { continue }
            life.append(WzMapLife(
                type: type, id: id,
                x: c.int("x") ?? 0,
                y: c.int("cy") ?? c.int("y") ?? 0,
                footholdID: c.int("fh") ?? 0,
                flipped: (c.int("f") ?? 0) != 0,
                hidden: (c.int("hide") ?? 0) != 0
            ))
        }

        // Portals
        var portals: [WzMapPortal] = []
        for entry in props["portal"]?.children ?? [] {
            let c = entry.value.children
            portals.append(WzMapPortal(
                name: c.string("pn") ?? "",
                type: c.int("pt") ?? 0,
                x: c.int("x") ?? 0,
                y: c.int("y") ?? 0,
                targetMap: c.int("tm") ?? 999_999_999,
                targetName: c.string("tn") ?? ""
            ))
        }

        let bounds = computeBounds(props: props, tiles: tiles, objects: objects)
        let spawn = portals.first
        let spawnX = spawn?.x ?? (bounds.left + bounds.right) / 2
        let spawnY = spawn?.y ?? bounds.bottom

        return WzLoadedMap(id: mapID, backgrounds: backgrounds, foregrounds: foregrounds,
                           tiles: tiles, objects: objects,
                           left: bounds.left, top: bounds.top, right: bounds.right, bottom: bounds.bottom,
                           spawnX: spawnX, spawnY: spawnY, footholds: footholds, life: life,
                           portals: portals)
    }

    /// Decode the animated portal swirl from `MapHelper.img/portal/game/pv`.
    public func loadPortalAnimation() throws -> [WzSpriteFrame] {
        guard let container = try imageProperties("MapHelper.img")?.property(at: "portal/game/pv")?.children else {
            return []
        }
        let indices = container.map(\.name).compactMap(Int.init).sorted()
        var frames: [WzSpriteFrame] = []
        for index in indices {
            guard let node = container["\(index)"],
                  let canvas = presentationCanvas(of: node, depth: 0),
                  let pixels = try pixelCanvas(for: canvas, imagePath: "MapHelper.img", depth: 0),
                  pixels.dataLength > 0,
                  let bitmap = try? archive.decodeCanvas(pixels) else { continue }
            let origin = canvas.properties.vector("origin") ?? (0, 0)
            let delay = canvas.properties.int("delay") ?? 100
            frames.append(WzSpriteFrame(rgba: bitmap.rgba, width: bitmap.width, height: bitmap.height,
                                        originX: origin.x, originY: origin.y,
                                        delayMilliseconds: max(delay, 1)))
        }
        return frames
    }

    // MARK: - Sprite resolution

    private struct DecodedSprite {
        var rgba: [UInt8]
        var width: Int
        var height: Int
        var originX: Int
        var originY: Int
        /// The canvas's own z: `z`, or `zM` when `z` is zero (HeavenClient's
        /// `Tile::Tile` rule). Used when the placement carries no z (tiles).
        var canvasZ: Int
    }

    /// - Parameter z: the placement's z (objects), or `nil` to use the canvas's
    ///   own z (tiles).
    private func sprite(imagePath: String, inner: String, x: Int, y: Int, layer: Int, z: Int?, flipped: Bool) throws -> WzMapSprite? {
        guard let decoded = try decodeSprite(imagePath: imagePath, inner: inner) else { return nil }
        let frames = try decodeAnimationFrames(imagePath: imagePath, inner: inner, firstFrame: decoded)
        return WzMapSprite(rgba: decoded.rgba, width: decoded.width, height: decoded.height,
                           x: x, y: y, originX: decoded.originX, originY: decoded.originY,
                           layer: layer, z: z ?? decoded.canvasZ, flipped: flipped,
                           frames: frames)
    }

    /// Decode every animation frame of a node. Static sprites yield a single
    /// frame built from `firstFrame`.
    private func decodeAnimationFrames(imagePath: String, inner: String, firstFrame: DecodedSprite) throws -> [WzSpriteFrame] {
        let fallback = [WzSpriteFrame(rgba: firstFrame.rgba, width: firstFrame.width, height: firstFrame.height,
                                      originX: firstFrame.originX, originY: firstFrame.originY,
                                      delayMilliseconds: 100)]
        guard let node = try imageProperties(imagePath)?.property(at: inner) else { return fallback }
        // Only containers with numeric children are animations.
        guard node.canvasValue == nil else { return fallback }
        let indices = node.children.map(\.name).compactMap(Int.init).sorted()
        guard indices.count > 1 else { return fallback }

        var frames: [WzSpriteFrame] = []
        frames.reserveCapacity(indices.count)
        for index in indices {
            guard let frameNode = node.children["\(index)"],
                  let canvas = presentationCanvas(of: frameNode, depth: 0),
                  let pixels = try pixelCanvas(for: canvas, imagePath: imagePath, depth: 0),
                  pixels.dataLength > 0,
                  let bitmap = try? archive.decodeCanvas(pixels) else { continue }
            let origin = canvas.properties.vector("origin") ?? (0, 0)
            let delay = canvas.properties.int("delay") ?? 100
            frames.append(WzSpriteFrame(rgba: bitmap.rgba, width: bitmap.width, height: bitmap.height,
                                        originX: origin.x, originY: origin.y,
                                        delayMilliseconds: max(delay, 1)))
        }
        return frames.isEmpty ? fallback : frames
    }

    private func decodeSprite(imagePath: String, inner: String) throws -> DecodedSprite? {
        guard let node = try imageProperties(imagePath)?.property(at: inner) else { return nil }
        // The presentation canvas (frame 0 of an animation) owns the origin/anchor
        // data - even when its pixels are delegated elsewhere via _inlink/_outlink.
        guard let presentation = presentationCanvas(of: node, depth: 0) else { return nil }
        let origin = presentation.properties.vector("origin") ?? (0, 0)
        let z = presentation.properties.int("z") ?? 0
        let canvasZ = z != 0 ? z : (presentation.properties.int("zM") ?? 0)
        guard let pixels = try pixelCanvas(for: presentation, imagePath: imagePath, depth: 0),
              pixels.dataLength > 0 else { return nil }
        let bitmap = try archive.decodeCanvas(pixels)
        return DecodedSprite(rgba: bitmap.rgba, width: bitmap.width, height: bitmap.height,
                             originX: origin.x, originY: origin.y, canvasZ: canvasZ)
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
