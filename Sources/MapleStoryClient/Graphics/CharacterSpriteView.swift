//
//  CharacterSpriteView.swift
//  MapleStoryClient
//
//  Draws a layered WZ character animation in screen space, for UI like the
//  character-select screen. Parts attach to the body skeleton via named anchor
//  points, the same assembly the in-game player renderer uses.
//

import Foundation
import MapleStoryFile

/// A ready-to-draw layered character animation (e.g. a stand pose).
public final class CharacterSpriteView {

    private struct PartTexture {
        var texture: Texture
        var part: WzCharacterPart
    }

    private struct FrameTextures {
        var delayMilliseconds: Int
        var parts: [PartTexture]
    }

    private let animation: WzCharacterAnimation
    private var frames: [FrameTextures] = []
    private var built = false

    public init(animation: WzCharacterAnimation) {
        self.animation = animation
    }

    /// Upload one texture per part (first draw only; requires the GL context).
    private func build() {
        frames = animation.frames.map { frame in
            let parts = frame.parts.compactMap { part -> PartTexture? in
                guard part.width > 0, part.height > 0,
                      let texture = try? Texture(width: part.width, height: part.height, rgba: part.rgba) else {
                    return nil
                }
                return PartTexture(texture: texture, part: part)
            }
            return FrameTextures(delayMilliseconds: frame.delayMilliseconds, parts: parts)
        }
        built = true
    }

    /// Draw the animation with the body's root anchor (the feet) at
    /// (`x`, `y`) in screen coordinates. Base art faces left; `flip` mirrors it.
    public func draw(x: Float, y: Float, flip: Bool = false, time: Double = 0, renderer: SpriteRenderer) {
        if built == false { build() }
        guard frames.isEmpty == false else { return }

        // Pick the frame for `time` over the looped animation.
        var frame = frames[0]
        let total = frames.reduce(0) { $0 + max($1.delayMilliseconds, 1) }
        if frames.count > 1, total > 0 {
            var cycle = Int(time * 1000) % total
            for candidate in frames {
                cycle -= max(candidate.delayMilliseconds, 1)
                if cycle < 0 {
                    frame = candidate
                    break
                }
            }
        }

        guard let body = frame.parts.first(where: { $0.part.anchor == .root }) else { return }
        let bodyOrigin = (x: Double(x), y: Double(y))
        let bodyNavel = add(bodyOrigin, body.part.point("navel"))
        let bodyNeck = add(bodyOrigin, body.part.point("neck"))

        var headBrow = bodyNeck
        if let head = frame.parts.first(where: { $0.part.zLayer == "head" }) {
            let headOrigin = subtract(bodyNeck, head.part.point("neck"))
            headBrow = add(headOrigin, head.part.point("brow"))
        }
        var armHand = bodyNavel
        if let arm = frame.parts.first(where: { $0.part.zLayer == "arm" }) {
            let armOrigin = subtract(bodyNavel, arm.part.point("navel"))
            armHand = add(armOrigin, arm.part.point("hand"))
        }

        for part in frame.parts {
            let anchorPoint: (x: Double, y: Double)
            switch part.part.anchor {
            case .root:  anchorPoint = bodyOrigin
            case .navel: anchorPoint = subtract(bodyNavel, part.part.point("navel"))
            case .neck:  anchorPoint = subtract(bodyNeck, part.part.point("neck"))
            case .brow:  anchorPoint = subtract(headBrow, part.part.point("brow"))
            case .hand:  anchorPoint = subtract(armHand, part.part.point("hand"))
            }
            draw(part, atOrigin: anchorPoint, pivotX: Double(x), flip: flip, renderer: renderer)
        }
    }

    private func draw(_ part: PartTexture, atOrigin origin: (x: Double, y: Double),
                      pivotX: Double, flip: Bool, renderer: SpriteRenderer) {
        let topLeftY = origin.y - Double(part.part.originY)
        var topLeftX = origin.x - Double(part.part.originX)
        if flip {
            topLeftX = 2 * pivotX - topLeftX - Double(part.part.width)
        }
        let rect = Rectangle(x: Float(topLeftX), y: Float(topLeftY),
                             width: Float(part.part.width), height: Float(part.part.height))
        let uv = flip ? Rectangle(x: 1, y: 0, width: -1, height: 1)
                      : Rectangle(x: 0, y: 0, width: 1, height: 1)
        renderer.draw(part.texture, in: rect, uv: uv)
    }

    private func add(_ origin: (x: Double, y: Double), _ point: (x: Int, y: Int)) -> (x: Double, y: Double) {
        (origin.x + Double(point.x), origin.y + Double(point.y))
    }

    private func subtract(_ origin: (x: Double, y: Double), _ point: (x: Int, y: Int)) -> (x: Double, y: Double) {
        (origin.x - Double(point.x), origin.y - Double(point.y))
    }
}
