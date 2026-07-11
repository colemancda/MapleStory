//
//  ImageDecoder.swift
//  MapleStoryClient
//
//  Decodes image files (PNG, etc.) to tightly-packed RGBA8 pixels ready for
//  upload as a ``Texture``. macOS-native via CoreGraphics/ImageIO, so it works
//  for any image asset regardless of the WZ pipeline that produced it.
//

import Foundation
import CoreGraphics
import ImageIO

/// Decoded RGBA8 pixel data.
public struct DecodedImage: Sendable {
    public let width: Int
    public let height: Int
    public let rgba: [UInt8]
}

public enum ImageDecoder {

    /// Decode an image file at `url` to RGBA8 pixels.
    public static func decode(contentsOf url: URL) throws -> DecodedImage {
        guard let source = CGImageSourceCreateWithURL(url as CFURL, nil),
              let image = CGImageSourceCreateImageAtIndex(source, 0, nil) else {
            throw ClientGraphicsError.imageDecodeFailed
        }
        return try decode(image)
    }

    /// Rasterize a `CGImage` to tightly-packed RGBA8 pixels.
    public static func decode(_ image: CGImage) throws -> DecodedImage {
        let width = image.width
        let height = image.height
        guard width > 0, height > 0 else {
            throw ClientGraphicsError.imageDecodeFailed
        }
        let bytesPerRow = width * 4
        var rgba = [UInt8](repeating: 0, count: bytesPerRow * height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let success = rgba.withUnsafeMutableBytes { buffer -> Bool in
            guard let context = CGContext(
                data: buffer.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            ) else {
                return false
            }
            context.draw(image, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
            return true
        }
        guard success else {
            throw ClientGraphicsError.imageDecodeFailed
        }
        return DecodedImage(width: width, height: height, rgba: rgba)
    }
}
