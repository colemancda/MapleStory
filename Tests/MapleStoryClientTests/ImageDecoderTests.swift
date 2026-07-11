//
//  ImageDecoderTests.swift
//  MapleStoryClientTests
//

import XCTest
import CoreGraphics
@testable import MapleStoryClient

final class ImageDecoderTests: XCTestCase {

    func testDecodesCGImageToRGBA() throws {
        let width = 3
        let height = 2
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        context.setFillColor(red: 1, green: 0, blue: 0, alpha: 1)
        context.fill(CGRect(x: 0, y: 0, width: width, height: height))
        let image = context.makeImage()!

        let decoded = try ImageDecoder.decode(image)

        XCTAssertEqual(decoded.width, 3)
        XCTAssertEqual(decoded.height, 2)
        XCTAssertEqual(decoded.rgba.count, 3 * 2 * 4)
        // First pixel is opaque red.
        XCTAssertEqual(decoded.rgba[0], 255)
        XCTAssertEqual(decoded.rgba[1], 0)
        XCTAssertEqual(decoded.rgba[2], 0)
        XCTAssertEqual(decoded.rgba[3], 255)
    }
}
