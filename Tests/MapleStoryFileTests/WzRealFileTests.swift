//
//  WzRealFileTests.swift
//  MapleStoryFileTests
//
//  Validation against a real binary WZ file (skipped when unavailable).
//

import XCTest
import Foundation
@testable import MapleStoryFile

final class WzRealFileTests: XCTestCase {

    private let basePath = "/Volumes/[C] Windows 11/Nexon/MapleStory62/Base.wz"

    func testParseRealBaseWz() throws {
        let url = URL(fileURLWithPath: basePath)
        guard FileManager.default.fileExists(atPath: basePath) else {
            throw XCTSkip("Base.wz not mounted")
        }
        let data = try Data(contentsOf: url)

        // Try GMS encryption first, then BMS (no string encryption).
        var archive: WzArchive?
        for version in [WzMapleVersion.gms, .bms] {
            if let parsed = try? WzArchive(data: data, mapleVersion: version) {
                if parsed.root.subdirectories.isEmpty == false || parsed.root.images.isEmpty == false {
                    archive = parsed
                    print("Parsed Base.wz with \(version), detected game version \(parsed.version)")
                    break
                }
            }
        }
        let wz = try XCTUnwrap(archive, "failed to parse Base.wz")

        print("Header: \(wz.header)")
        print("Root subdirectories: \(wz.root.subdirectories.map(\.name))")
        print("Root images: \(wz.root.images.map(\.name))")

        XCTAssertEqual(wz.header.ident, "PKG1")
        XCTAssertFalse(wz.root.images.isEmpty && wz.root.subdirectories.isEmpty)
    }

    private let uiPath = "/Volumes/[C] Windows 11/Nexon/MapleStory62/UI.wz"

    func testDecodeRealCanvas() throws {
        guard FileManager.default.fileExists(atPath: uiPath) else {
            throw XCTSkip("UI.wz not mounted")
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: uiPath))
        let wz = try XCTUnwrap(try? WzArchive(data: data, mapleVersion: .gms))
        print("UI.wz version \(wz.version); images: \(wz.root.images.map(\.name).prefix(8))")

        // Find the first canvas across the first few images.
        var found: WzCanvas?
        var imageName = ""
        for image in wz.root.images.prefix(12) {
            let properties = (try? wz.properties(of: image)) ?? []
            if let canvas = Self.firstCanvas(in: properties) {
                found = canvas
                imageName = image.name
                break
            }
        }
        let canvas = try XCTUnwrap(found, "no canvas found in UI.wz root images")
        print("Canvas in \(imageName): \(canvas.width)x\(canvas.height) format \(canvas.format), \(canvas.dataLength) compressed bytes")

        let bitmap = try wz.decodeCanvas(canvas)
        XCTAssertEqual(bitmap.width, canvas.width)
        XCTAssertEqual(bitmap.height, canvas.height)
        XCTAssertEqual(bitmap.rgba.count, canvas.width * canvas.height * 4)
        // A real sprite should have at least one non-transparent pixel.
        let hasVisiblePixel = stride(from: 3, to: bitmap.rgba.count, by: 4).contains { bitmap.rgba[$0] != 0 }
        XCTAssertTrue(hasVisiblePixel, "decoded canvas is fully transparent")
    }

    private static func firstCanvas(in properties: [WzNamedProperty]) -> WzCanvas? {
        for property in properties {
            switch property.value {
            case .canvas(let canvas) where canvas.width > 0 && canvas.height > 0:
                return canvas
            case .sub(let children):
                if let canvas = firstCanvas(in: children) { return canvas }
            default:
                break
            }
        }
        return nil
    }
}
