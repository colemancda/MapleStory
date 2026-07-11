//
//  WzBitmap.swift
//  MapleStoryFile
//
//  Decodes a WZ canvas's compressed bitmap into RGBA8 pixels, ported from
//  MapleLib's WzPngProperty. Supports the non-DXT pixel formats used by
//  v62-era clients (BGRA4444, BGRA8888, RGB565, ARGB1555).
//

import Foundation
import CZlibShim

/// Decoded RGBA8 bitmap.
public struct WzDecodedBitmap: Sendable {
    public let width: Int
    public let height: Int
    public let rgba: [UInt8]
}

public enum WzBitmapError: Error {
    case unsupportedFormat(Int)
    case decompressionFailed
}

enum WzBitmap {

    /// Uncompressed byte size for a supported pixel format.
    static func decodedSize(format: Int, width: Int, height: Int) throws -> Int {
        switch format {
        case 1: return width * height * 2   // BGRA4444
        case 2: return width * height * 4   // BGRA8888
        case 257: return width * height * 2 // ARGB1555
        case 513: return width * height * 2 // RGB565
        default: throw WzBitmapError.unsupportedFormat(format)
        }
    }

    /// Decode a canvas payload to RGBA8.
    static func decode(canvas: WzCanvas, compressed: [UInt8], key: WzMutableKey) throws -> WzDecodedBitmap {
        let size = try decodedSize(format: canvas.format, width: canvas.width, height: canvas.height)
        let deflateStream = try dechunk(compressed, key: key)
        let raw = try inflate(deflateStream, expectedSize: size)
        let rgba = try convert(raw, format: canvas.format, width: canvas.width, height: canvas.height)
        return WzDecodedBitmap(width: canvas.width, height: canvas.height, rgba: rgba)
    }

    // MARK: - Decompression

    /// If the payload isn't a standard zlib stream it is a "ListWz" chunked stream:
    /// `[Int32 length][XOR-encrypted bytes]` repeated; decrypt to recover the zlib stream.
    private static func dechunk(_ data: [UInt8], key: WzMutableKey) throws -> [UInt8] {
        guard data.count >= 2 else { throw WzBitmapError.decompressionFailed }
        let isStandardZlib = data[0] == 0x78 && [0x01, 0x5E, 0x9C, 0xDA].contains(data[1])
        if isStandardZlib {
            return data
        }
        var output: [UInt8] = []
        output.reserveCapacity(data.count)
        var i = 0
        while i + 4 <= data.count {
            let blockLength = Int(UInt32(data[i]) | (UInt32(data[i + 1]) << 8) | (UInt32(data[i + 2]) << 16) | (UInt32(data[i + 3]) << 24))
            i += 4
            guard blockLength >= 0, i + blockLength <= data.count else { break }
            key.ensure(size: blockLength)
            for j in 0 ..< blockLength {
                output.append(data[i + j] ^ key[j])
            }
            i += blockLength
        }
        return output
    }

    /// Raw DEFLATE inflate (the payload's first 2 bytes are the zlib header, which
    /// `COMPRESSION_ZLIB` — raw RFC-1951 — does not consume).
    /// Inflate a WZ bitmap stream. The 2-byte zlib header is dropped and the body
    /// is decoded as raw DEFLATE (WZ omits the adler32 trailer).
    private static func inflate(_ zlibStream: [UInt8], expectedSize: Int) throws -> [UInt8] {
        guard zlibStream.count > 2 else { throw WzBitmapError.decompressionFailed }
        let deflate = Array(zlibStream[2...])
        let capacity = max(expectedSize + 64, expectedSize)
        var destination = [UInt8](repeating: 0, count: capacity)
        let written = deflate.withUnsafeBufferPointer { source in
            destination.withUnsafeMutableBufferPointer { dst in
                wz_raw_inflate(source.baseAddress, Int(source.count), dst.baseAddress, Int(dst.count))
            }
        }
        guard written >= expectedSize else { throw WzBitmapError.decompressionFailed }
        if destination.count > expectedSize {
            destination.removeLast(destination.count - expectedSize)
        }
        return destination
    }

    // MARK: - Pixel conversion

    @inline(__always) private static func expand4(_ nibble: UInt8) -> UInt8 {
        (nibble << 4) | nibble
    }

    private static func convert(_ raw: [UInt8], format: Int, width: Int, height: Int) throws -> [UInt8] {
        let pixelCount = width * height
        var rgba = [UInt8](repeating: 0, count: pixelCount * 4)
        switch format {
        case 2: // BGRA8888
            guard raw.count >= pixelCount * 4 else { throw WzBitmapError.decompressionFailed }
            for p in 0 ..< pixelCount {
                rgba[p * 4 + 0] = raw[p * 4 + 2] // R
                rgba[p * 4 + 1] = raw[p * 4 + 1] // G
                rgba[p * 4 + 2] = raw[p * 4 + 0] // B
                rgba[p * 4 + 3] = raw[p * 4 + 3] // A
            }
        case 1: // BGRA4444
            guard raw.count >= pixelCount * 2 else { throw WzBitmapError.decompressionFailed }
            for p in 0 ..< pixelCount {
                let lo = raw[p * 2]
                let hi = raw[p * 2 + 1]
                rgba[p * 4 + 2] = expand4(lo & 0x0F)        // B
                rgba[p * 4 + 1] = expand4(lo >> 4)          // G
                rgba[p * 4 + 0] = expand4(hi & 0x0F)        // R
                rgba[p * 4 + 3] = expand4(hi >> 4)          // A
            }
        case 513: // RGB565
            guard raw.count >= pixelCount * 2 else { throw WzBitmapError.decompressionFailed }
            for p in 0 ..< pixelCount {
                let value = UInt16(raw[p * 2]) | (UInt16(raw[p * 2 + 1]) << 8)
                let r = UInt8((value >> 11) & 0x1F)
                let g = UInt8((value >> 5) & 0x3F)
                let b = UInt8(value & 0x1F)
                rgba[p * 4 + 0] = (r << 3) | (r >> 2)
                rgba[p * 4 + 1] = (g << 2) | (g >> 4)
                rgba[p * 4 + 2] = (b << 3) | (b >> 2)
                rgba[p * 4 + 3] = 255
            }
        case 257: // ARGB1555
            guard raw.count >= pixelCount * 2 else { throw WzBitmapError.decompressionFailed }
            for p in 0 ..< pixelCount {
                let value = UInt16(raw[p * 2]) | (UInt16(raw[p * 2 + 1]) << 8)
                let a = (value >> 15) & 0x1
                let r = UInt8((value >> 10) & 0x1F)
                let g = UInt8((value >> 5) & 0x1F)
                let b = UInt8(value & 0x1F)
                rgba[p * 4 + 0] = (r << 3) | (r >> 2)
                rgba[p * 4 + 1] = (g << 3) | (g >> 2)
                rgba[p * 4 + 2] = (b << 3) | (b >> 2)
                rgba[p * 4 + 3] = a == 1 ? 255 : 0
            }
        default:
            throw WzBitmapError.unsupportedFormat(format)
        }
        return rgba
    }
}
