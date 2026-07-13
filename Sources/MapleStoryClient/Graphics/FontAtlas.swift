//
//  FontAtlas.swift
//  MapleStoryClient
//
//  Rasterizes a monospaced ASCII font into a single-row RGBA atlas using CoreText.
//  macOS-native, so no FreeType/SDL_ttf dependency for basic UI text.
//

import Foundation
import CoreText
import CoreGraphics

/// A rasterized monospaced bitmap font covering printable ASCII (32...126).
struct FontAtlas {

    static let firstCharacter: UInt8 = 32
    static let characterCount = 95   // 32...126 inclusive

    let pixels: [UInt8]      // RGBA8, tightly packed
    let width: Int
    let height: Int
    let cellWidth: Int
    let cellHeight: Int

    init(fontName: String = "Menlo", pointSize: CGFloat = 32) throws {
        let font = CTFontCreateWithName(fontName as CFString, pointSize, nil)

        let ascent = CTFontGetAscent(font)
        let descent = CTFontGetDescent(font)
        let leading = CTFontGetLeading(font)
        let cellHeight = Int(ceil(ascent + descent + leading)) + 2

        // Monospaced advance, measured on a wide glyph.
        var mChars: [UniChar] = Array("M".utf16)
        var mGlyphs = [CGGlyph](repeating: 0, count: mChars.count)
        CTFontGetGlyphsForCharacters(font, &mChars, &mGlyphs, mChars.count)
        let advance = CTFontGetAdvancesForGlyphs(font, .horizontal, &mGlyphs, nil, 1)
        let cellWidth = Int(ceil(advance)) + 2

        let width = cellWidth * FontAtlas.characterCount
        let height = cellHeight

        let bytesPerRow = width * 4
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw ClientGraphicsError.fontRasterizationFailed
        }

        // Transparent background, white glyphs (tinted at draw time).
        //
        // Draw in the context's default y-up coordinates: CTFontDrawGlyphs
        // assumes y-up outlines, and the bitmap's memory row 0 is already the
        // image top. (A y-flip transform here renders every glyph upside-down.)
        context.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)

        for index in 0 ..< FontAtlas.characterCount {
            let scalar = UnicodeScalar(UInt32(FontAtlas.firstCharacter) + UInt32(index))!
            var chars = Array(String(scalar).utf16)
            var glyphs = [CGGlyph](repeating: 0, count: chars.count)
            CTFontGetGlyphsForCharacters(font, &chars, &glyphs, chars.count)
            let originX = CGFloat(index * cellWidth) + 1
            var positions = [CGPoint(x: originX, y: descent)]
            CTFontDrawGlyphs(font, &glyphs, &positions, 1, context)
        }

        guard let data = context.data else {
            throw ClientGraphicsError.fontRasterizationFailed
        }
        let buffer = data.bindMemory(to: UInt8.self, capacity: bytesPerRow * height)
        self.pixels = Array(UnsafeBufferPointer(start: buffer, count: bytesPerRow * height))
        self.width = width
        self.height = height
        self.cellWidth = cellWidth
        self.cellHeight = cellHeight
    }

    /// The atlas sub-rectangle (UV, 0...1) for a character.
    func uv(for character: Character) -> Rectangle? {
        guard let ascii = character.asciiValue,
              ascii >= FontAtlas.firstCharacter,
              Int(ascii) < Int(FontAtlas.firstCharacter) + FontAtlas.characterCount
        else { return nil }
        let index = Int(ascii - FontAtlas.firstCharacter)
        let u0 = Float(index * cellWidth) / Float(width)
        let uWidth = Float(cellWidth) / Float(width)
        return Rectangle(x: u0, y: 0, width: uWidth, height: 1)
    }
}
