//
//  TextRenderer.swift
//  MapleStoryClient
//

import Foundation

/// Draws strings using a ``FontAtlas`` uploaded to a GL texture.
public final class TextRenderer {

    private let atlas: FontAtlas
    private let texture: Texture

    /// The height, in pixels, of a glyph cell at scale `1`.
    public var lineHeight: Float { Float(atlas.cellHeight) }

    /// The width, in pixels, of a glyph cell at scale `1`.
    public var characterWidth: Float { Float(atlas.cellWidth) }

    public init(fontName: String = "Menlo", pointSize: CGFloat = 32) throws {
        let atlas = try FontAtlas(fontName: fontName, pointSize: pointSize)
        self.atlas = atlas
        self.texture = try Texture(width: atlas.width, height: atlas.height, rgba: atlas.pixels)
    }

    /// Width in pixels of `string` at `scale`.
    public func width(of string: String, scale: Float = 1) -> Float {
        Float(string.count) * Float(atlas.cellWidth) * scale
    }

    /// Draw `string` with its top-left at (`x`, `y`).
    public func draw(
        _ string: String,
        x: Float,
        y: Float,
        scale: Float = 1,
        color: RGBAColor = .white,
        using renderer: SpriteRenderer
    ) {
        var cursor = x
        let glyphWidth = Float(atlas.cellWidth) * scale
        let glyphHeight = Float(atlas.cellHeight) * scale
        for character in string {
            if let uv = atlas.uv(for: character) {
                let rect = Rectangle(x: cursor, y: y, width: glyphWidth, height: glyphHeight)
                renderer.draw(texture, in: rect, uv: uv, tint: color)
            }
            cursor += glyphWidth
        }
    }
}
