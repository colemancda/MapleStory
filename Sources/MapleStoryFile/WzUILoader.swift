//
//  WzUILoader.swift
//  MapleStoryFile
//
//  Decodes UI sprites from UI.wz (login screen, windows, buttons). UI nodes are
//  either a single canvas or a numbered animation container; canvases may
//  delegate their pixels within the same image via `_inlink`.
//

import Foundation

public final class WzUILoader {

    private let archive: WzArchive
    private var imageCache: [String: [WzNamedProperty]] = [:]

    public init(archive: WzArchive) {
        self.archive = archive
    }

    /// The parsed property tree of an image (cached).
    public func properties(image: String) throws -> [WzNamedProperty]? {
        if let cached = imageCache[image] { return cached }
        guard let node = archive.root[image] else { return nil }
        let props = try archive.properties(of: node)
        imageCache[image] = props
        return props
    }

    /// Decode the sprite at `image`/`path`: the canvas itself, or frame 0 of an
    /// animation container.
    public func sprite(image: String, path: String) throws -> WzSpriteFrame? {
        guard let props = try properties(image: image),
              let node = props.property(at: path) else { return nil }
        return try decode(node: node, rootProps: props)
    }

    /// Decode every numbered frame of the animation container at `image`/`path`.
    public func frames(image: String, path: String) throws -> [WzSpriteFrame] {
        guard let props = try properties(image: image),
              let container = props.property(at: path)?.children else { return [] }
        let indices = container.map(\.name).compactMap(Int.init).sorted()
        var frames: [WzSpriteFrame] = []
        for index in indices {
            guard let node = container["\(index)"],
                  let frame = try decode(node: node, rootProps: props) else { continue }
            frames.append(frame)
        }
        return frames
    }

    private func decode(node: WzProperty, rootProps: [WzNamedProperty]) throws -> WzSpriteFrame? {
        // A container (animation/button state) presents through its first frame.
        var presentation = node
        var depth = 0
        while presentation.canvasValue == nil, depth < 4 {
            guard let first = presentation.children.first(where: { Int($0.name) != nil })?.value else { break }
            presentation = first
            depth += 1
        }
        guard var canvas = presentation.canvasValue else { return nil }
        let origin = canvas.properties.vector("origin") ?? (0, 0)
        let delay = canvas.properties.int("delay") ?? 100
        if canvas.dataLength == 0, let inlink = canvas.properties.string("_inlink"),
           let target = rootProps.property(at: inlink)?.canvasValue {
            canvas = target
        }
        guard canvas.dataLength > 0 else { return nil }
        let bitmap = try archive.decodeCanvas(canvas)
        return WzSpriteFrame(rgba: bitmap.rgba, width: bitmap.width, height: bitmap.height,
                             originX: origin.x, originY: origin.y,
                             delayMilliseconds: max(delay, 1))
    }
}
