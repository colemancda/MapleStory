//
//  WzCharacterLoader.swift
//  MapleStoryFile
//
//  Loads a layered MapleStory character (body/arm/head/face) from Character.wz,
//  following the node layout MapleNecrocer/the reference client use:
//    body: Character/{2000+skin:08}.img/{action}/{frame}/body|arm  (canvas, each
//          with "map" anchor points, e.g. body has "navel"/"neck", arm has "navel"/"hand")
//    head: Character/{12000+skin:08}.img/{action}/{frame}/head  (a UOL alias
//          into that same image's "front"/"head" canvas, which has "map" points
//          "neck"/"brow"/...)
//    face: Character/Face/{faceID:08}.img/default/face  (a static canvas with
//          its own "map" "brow" point)
//
//  Parts are attached to each other by matching same-named anchor points, which
//  are defined relative to each canvas's own "origin" (not its top-left corner).
//

import Foundation

/// A single decoded body part, ready to be positioned via anchor-point matching.
public struct WzCharacterPart: Sendable {
    public var rgba: [UInt8]
    public var width: Int
    public var height: Int
    /// The canvas's own hotspot, in bitmap pixel coordinates (top-left origin).
    public var originX: Int
    public var originY: Int
    /// Named anchor points, relative to (originX, originY).
    public var mapPoints: [String: (x: Int, y: Int)]

    public func point(_ name: String) -> (x: Int, y: Int) {
        mapPoints[name] ?? (0, 0)
    }
}

/// One frame of a character animation: its parts and how long to hold it.
public struct WzCharacterFrame: Sendable {
    public var delayMilliseconds: Int
    public var body: WzCharacterPart?
    public var arm: WzCharacterPart?
    public var head: WzCharacterPart?
    public var face: WzCharacterPart?
    /// Whether the face is visible this frame (climbing poses show the
    /// character from behind, flagged by the frame's `face` int being 0).
    public var showFace: Bool = true
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
}

public final class WzCharacterLoader {

    private let archive: WzArchive
    private var imageCache: [String: [WzNamedProperty]] = [:]

    public init(archive: WzArchive) {
        self.archive = archive
    }

    /// Load a character by skin ID (0 = default) and face ID (e.g. 20000).
    public func load(skin: Int = 0, faceID: Int = 20000) throws -> WzLoadedCharacter {
        let bodyPath = String(format: "%08d.img", 2000 + skin)
        let headPath = String(format: "%08d.img", 12000 + skin)
        let facePath = "Face/" + String(format: "%08d.img", faceID)

        guard let bodyProps = try imageProperties(bodyPath) else {
            throw WzArchiveError.invalidHeader
        }
        let headProps = try imageProperties(headPath)
        let faceProps = try imageProperties(facePath)

        // Face has one static pose, reused across every frame.
        let face: WzCharacterPart?
        if let faceProps, let faceNode = faceProps["default"]?.children["face"] {
            face = decodePart(node: faceNode, currentPath: ["default", "face"], rootProps: faceProps)
        } else {
            face = nil
        }

        let stand = try loadAnimation(action: "stand1", bodyProps: bodyProps, headProps: headProps, face: face)
        let walk = try loadAnimation(action: "walk1", bodyProps: bodyProps, headProps: headProps, face: face)
        let jump = try loadAnimation(action: "jump", bodyProps: bodyProps, headProps: headProps, face: face)
        let ladder = try loadAnimation(action: "ladder", bodyProps: bodyProps, headProps: headProps, face: face)
        let rope = try loadAnimation(action: "rope", bodyProps: bodyProps, headProps: headProps, face: face)
        return WzLoadedCharacter(stand: stand, walk: walk, jump: jump, ladder: ladder, rope: rope)
    }

    private func loadAnimation(
        action: String,
        bodyProps: [WzNamedProperty],
        headProps: [WzNamedProperty]?,
        face: WzCharacterPart?
    ) throws -> WzCharacterAnimation {
        guard let bodyFrames = bodyProps[action]?.children else {
            return WzCharacterAnimation(frames: [])
        }
        let headFrames = headProps?[action]?.children

        let indices = bodyFrames.map(\.name).compactMap(Int.init).sorted()
        var frames: [WzCharacterFrame] = []
        frames.reserveCapacity(indices.count)

        for index in indices {
            guard let frameChildren = bodyFrames["\(index)"]?.children else { continue }
            let delay = frameChildren.int("delay") ?? 100

            let body = frameChildren["body"].flatMap {
                decodePart(node: $0, currentPath: [action, "\(index)", "body"], rootProps: bodyProps)
            }
            let arm = frameChildren["arm"].flatMap {
                decodePart(node: $0, currentPath: [action, "\(index)", "arm"], rootProps: bodyProps)
            }
            var head: WzCharacterPart?
            if let headProps, let headFrames, let headNode = headFrames["\(index)"]?.children["head"] {
                head = decodePart(node: headNode, currentPath: [action, "\(index)", "head"], rootProps: headProps)
            }

            // The frame's `face` int flags visibility (0 = seen from behind).
            let showFace = (frameChildren.int("face") ?? 1) != 0
            frames.append(WzCharacterFrame(delayMilliseconds: delay, body: body, arm: arm, head: head,
                                           face: face, showFace: showFace))
        }
        return WzCharacterAnimation(frames: frames)
    }

    // MARK: - Node resolution

    /// Resolve `node` (following UOL aliases and canvas `_inlink`s) and decode it.
    private func decodePart(node: WzProperty, currentPath: [String], rootProps: [WzNamedProperty]) -> WzCharacterPart? {
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
        return WzCharacterPart(rgba: bitmap.rgba, width: bitmap.width, height: bitmap.height,
                               originX: origin.x, originY: origin.y, mapPoints: mapPoints)
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
