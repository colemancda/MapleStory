//
//  WzCharacterLoader.swift
//  MapleStoryFile
//
//  Loads a layered MapleStory character from Character.wz: the base body/head/face
//  plus equipment (hair, coat, pants, shoes, cap, ...). Every part is a canvas
//  carrying a `z` layer name and `map` anchor points; parts attach to each other
//  by matching same-named points (e.g. a coat's "navel" to the body's "navel",
//  hair's "brow" to the head's "brow") and draw in the global zmap order.
//
//    body: Character/{2000+skin:08}.img/{action}/{frame}/{body,arm,...}
//    head: Character/{12000+skin:08}.img/{action}/{frame}/head  (UOL to front/head)
//    face: Character/Face/{faceID:08}.img/default/face
//    equip: Character/{Category}/{id:08}.img/{action}/{frame}/{part...}
//

import Foundation

/// How a part attaches to the body skeleton.
public enum WzCharacterAnchor: Sendable {
    case root   // the body itself
    case navel  // align the part's "navel" to the body's "navel"
    case neck   // align the part's "neck" to the body's "neck" (the head)
    case brow   // align the part's "brow" to the head's "brow"
    case hand   // align the part's "hand" to the arm's "hand" (weapons, gloves)
}

/// A single decoded part, positioned via anchor-point matching and z-ordered.
public struct WzCharacterPart: Sendable {
    public var rgba: [UInt8]
    public var width: Int
    public var height: Int
    /// The canvas's own hotspot, in bitmap pixel coordinates (top-left origin).
    public var originX: Int
    public var originY: Int
    /// Named anchor points, relative to (originX, originY).
    public var mapPoints: [String: (x: Int, y: Int)]
    /// The zmap layer name (`z`), deciding draw order.
    public var zLayer: String
    public var anchor: WzCharacterAnchor

    public func point(_ name: String) -> (x: Int, y: Int) {
        mapPoints[name] ?? (0, 0)
    }
}

/// One frame of a character animation: its z-sorted parts and hold duration.
public struct WzCharacterFrame: Sendable {
    public var delayMilliseconds: Int
    /// Parts sorted back-to-front (draw in order).
    public var parts: [WzCharacterPart]
}

public struct WzCharacterAnimation: Sendable {
    public var frames: [WzCharacterFrame]
}

/// A loaded, ready-to-render character.
public struct WzLoadedCharacter: Sendable {
    public var stand: WzCharacterAnimation
    public var walk: WzCharacterAnimation
    public var jump: WzCharacterAnimation
    public var ladder: WzCharacterAnimation
    public var rope: WzCharacterAnimation
    /// One-handed swing attack (`swingO1`).
    public var attack: WzCharacterAnimation
    /// Lying down (holding the down arrow).
    public var prone: WzCharacterAnimation
}

/// An equipped item: its Character.wz subdirectory and item id.
public struct WzEquipItem: Sendable {
    public var category: String
    public var id: Int
    public init(category: String, id: Int) {
        self.category = category
        self.id = id
    }
    var imagePath: String { "\(category)/" + String(format: "%08d.img", id) }
}

public final class WzCharacterLoader {

    private let archive: WzArchive
    private let zmap: WzZmap
    private var imageCache: [String: [WzNamedProperty]] = [:]

    public init(archive: WzArchive, zmap: WzZmap = WzZmap(order: [:])) {
        self.archive = archive
        self.zmap = zmap
    }

    /// Load a character by skin/face plus optional equipment.
    public func load(skin: Int = 0, faceID: Int = 20000, equipment: [WzEquipItem] = []) throws -> WzLoadedCharacter {
        let bodyPath = String(format: "%08d.img", 2000 + skin)
        let headPath = String(format: "%08d.img", 12000 + skin)
        let facePath = "Face/" + String(format: "%08d.img", faceID)

        guard let bodyProps = try imageProperties(bodyPath) else {
            throw WzArchiveError.invalidHeader
        }
        let headProps = try imageProperties(headPath)
        let faceProps = try imageProperties(facePath)
        let equipData: [(category: String, props: [WzNamedProperty])] = try equipment.compactMap { item in
            try imageProperties(item.imagePath).map { (item.category, $0) }
        }
        let equipProps = equipData.map(\.props)

        // A non-hair item (cap/helmet) whose `vslot` covers front hair ("H1")
        // hides the hair. The hair's own vslot lists "H1" too, so exclude it.
        let hideHair = equipData.contains { entry in
            entry.category != "Hair" && (entry.props.string("info/vslot") ?? "").contains("H1")
        }

        // Face has one static pose, reused across every (front-facing) frame.
        let face: WzCharacterPart?
        if let faceProps, let faceNode = faceProps["default"]?.children["face"] {
            face = decodePart(node: faceNode, name: "face", currentPath: ["default", "face"], rootProps: faceProps)
        } else {
            face = nil
        }

        func animation(_ action: String) throws -> WzCharacterAnimation {
            try loadAnimation(action: action, bodyProps: bodyProps, headProps: headProps,
                              face: face, equipProps: equipProps, hideHair: hideHair)
        }
        return WzLoadedCharacter(
            stand: try animation("stand1"),
            walk: try animation("walk1"),
            jump: try animation("jump"),
            ladder: try animation("ladder"),
            rope: try animation("rope"),
            attack: try animation("swingO1"),
            prone: try animation("prone")
        )
    }

    private func loadAnimation(
        action: String,
        bodyProps: [WzNamedProperty],
        headProps: [WzNamedProperty]?,
        face: WzCharacterPart?,
        equipProps: [[WzNamedProperty]],
        hideHair: Bool
    ) throws -> WzCharacterAnimation {
        guard let bodyFrames = bodyProps[action]?.children else {
            return WzCharacterAnimation(frames: [])
        }
        let indices = bodyFrames.map(\.name).compactMap(Int.init).sorted()
        var frames: [WzCharacterFrame] = []
        frames.reserveCapacity(indices.count)

        for index in indices {
            guard let frameChildren = bodyFrames["\(index)"]?.children else { continue }
            let delay = frameChildren.int("delay") ?? 100
            let showFace = (frameChildren.int("face") ?? 1) != 0

            var parts: [WzCharacterPart] = []

            // Body parts (body, arm, lHand, rHand, ...): every canvas child.
            addParts(from: frameChildren, action: action, index: index, rootProps: bodyProps, into: &parts)

            // Head (UOL to front/head).
            if let headProps, let headFrames = headProps[action]?.children,
               let headNode = headFrames["\(index)"]?.children["head"],
               let head = decodePart(node: headNode, name: "head", currentPath: [action, "\(index)", "head"], rootProps: headProps) {
                parts.append(head)
            }

            // Face (shared static pose), when visible.
            if showFace, let face { parts.append(face) }

            // Equipment parts for this action/frame.
            for equip in equipProps {
                guard let equipFrame = equip[action]?.children["\(index)"]?.children else { continue }
                addParts(from: equipFrame, action: action, index: index, rootProps: equip, into: &parts)
            }

            // A hair-covering cap hides every hair layer.
            if hideHair {
                parts.removeAll { $0.zLayer.lowercased().contains("hair") }
            }

            // Back-to-front: higher zmap index draws first.
            parts.sort { zmap.priority(of: $0.zLayer) > zmap.priority(of: $1.zLayer) }
            frames.append(WzCharacterFrame(delayMilliseconds: delay, parts: parts))
        }
        return WzCharacterAnimation(frames: frames)
    }

    /// Decode every canvas child of a frame node into parts.
    private func addParts(from frame: [WzNamedProperty], action: String, index: Int,
                          rootProps: [WzNamedProperty], into parts: inout [WzCharacterPart]) {
        for entry in frame {
            if let part = decodePart(node: entry.value, name: entry.name,
                                     currentPath: [action, "\(index)", entry.name], rootProps: rootProps) {
                parts.append(part)
            }
        }
    }

    // MARK: - Node resolution

    /// Resolve `node` (following UOL aliases and canvas `_inlink`s) and decode it.
    private func decodePart(node: WzProperty, name: String, currentPath: [String], rootProps: [WzNamedProperty]) -> WzCharacterPart? {
        guard let (resolved, _) = resolve(node, currentPath: currentPath, rootProps: rootProps) else { return nil }
        guard case let .canvas(canvas) = resolved, canvas.dataLength > 0 else { return nil }
        guard let bitmap = try? archive.decodeCanvas(canvas) else { return nil }

        let origin = canvas.properties.vector("origin") ?? (0, 0)
        var mapPoints: [String: (x: Int, y: Int)] = [:]
        for entry in canvas.properties["map"]?.children ?? [] {
            if let vector = entry.value.vectorValue {
                mapPoints[entry.name] = vector
            }
        }
        let zLayer = canvas.properties.string("z") ?? name
        let anchor = WzCharacterLoader.inferAnchor(zLayer: zLayer, mapKeys: Set(mapPoints.keys))
        return WzCharacterPart(rgba: bitmap.rgba, width: bitmap.width, height: bitmap.height,
                               originX: origin.x, originY: origin.y, mapPoints: mapPoints,
                               zLayer: zLayer, anchor: anchor)
    }

    private static func inferAnchor(zLayer: String, mapKeys: Set<String>) -> WzCharacterAnchor {
        if zLayer == "body" { return .root }
        if zLayer == "head" { return .neck }
        // Navel wins over hand: the arm carries both but is body-attached.
        if mapKeys.contains("navel") { return .navel }
        if mapKeys.contains("hand") { return .hand }
        if mapKeys.contains("brow") { return .brow }
        return .navel
    }

    private func resolve(_ node: WzProperty, currentPath: [String], rootProps: [WzNamedProperty]) -> (WzProperty, [String])? {
        switch node {
        case .uol(let target):
            let basePath = Array(currentPath.dropLast())
            let resolvedPath = WzCharacterLoader.resolvePath(base: basePath, relative: target)
            guard let resolvedNode = WzCharacterLoader.navigate(rootProps, path: resolvedPath) else { return nil }
            return resolve(resolvedNode, currentPath: resolvedPath, rootProps: rootProps)
        case .canvas(let canvas) where canvas.dataLength == 0:
            if let inlink = canvas.properties.string("_inlink") {
                let resolvedPath = inlink.split(separator: "/").map(String.init)
                guard let resolvedNode = WzCharacterLoader.navigate(rootProps, path: resolvedPath) else { return nil }
                return resolve(resolvedNode, currentPath: resolvedPath, rootProps: rootProps)
            }
            return (node, currentPath)
        default:
            return (node, currentPath)
        }
    }

    private static func navigate(_ props: [WzNamedProperty], path: [String]) -> WzProperty? {
        var current = props
        var result: WzProperty?
        for component in path {
            guard let value = current[component] else { return nil }
            result = value
            current = value.children
        }
        return result
    }

    private static func resolvePath(base: [String], relative: String) -> [String] {
        var path = base
        for component in relative.split(separator: "/") {
            if component == ".." {
                if path.isEmpty == false { path.removeLast() }
            } else if component == "." {
                continue
            } else {
                path.append(String(component))
            }
        }
        return path
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
