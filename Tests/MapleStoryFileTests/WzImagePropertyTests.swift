//
//  WzImagePropertyTests.swift
//  MapleStoryFileTests
//
//  Exercises the full WZ property tree (every value type, navigation helpers,
//  canvas/sound decoding) by building a synthetic archive in memory.
//

import XCTest
import Foundation
@testable import MapleStoryFile

final class WzImagePropertyTests: XCTestCase {

    private func propertiesOfSingleImage(_ entries: [[UInt8]]) throws -> (WzArchive, [WzNamedProperty]) {
        let data = WzFixtures.buildArchive(images: [("a.img", WzFixtures.image(entries))])
        let archive = try WzArchive(data: data, mapleVersion: .bms, version: 1)
        let image = try XCTUnwrap(archive.root["a.img"])
        return (archive, try archive.properties(of: image))
    }

    func testAllScalarValueTypes() throws {
        let (_, props) = try propertiesOfSingleImage([
            WzFixtures.property("nul", WzFixtures.null()),
            WzFixtures.property("i16", WzFixtures.int16(-1234)),
            WzFixtures.property("i32", WzFixtures.int32(70000)),      // escaped compressed int
            WzFixtures.property("i64", WzFixtures.int64(5_000_000_000)),
            WzFixtures.property("f0", WzFixtures.float(0)),
            WzFixtures.property("f", WzFixtures.float(2.5)),
            WzFixtures.property("d", WzFixtures.double(3.5)),
            WzFixtures.property("s", WzFixtures.string("hello")),
        ])

        XCTAssertEqual(props.count, 8)
        guard case .null = props["nul"] else { return XCTFail("null") }
        guard case .int16(let a) = props["i16"] else { return XCTFail("int16") }
        XCTAssertEqual(a, -1234)
        guard case .int32(let b) = props["i32"] else { return XCTFail("int32") }
        XCTAssertEqual(b, 70000)
        guard case .int64(let c) = props["i64"] else { return XCTFail("int64") }
        XCTAssertEqual(c, 5_000_000_000)
        guard case .float(let z) = props["f0"] else { return XCTFail("float0") }
        XCTAssertEqual(z, 0)
        guard case .float(let f) = props["f"] else { return XCTFail("float") }
        XCTAssertEqual(f, 2.5)
        guard case .double(let d) = props["d"] else { return XCTFail("double") }
        XCTAssertEqual(d, 3.5)
        XCTAssertEqual(props.string("s"), "hello")
    }

    func testValueAccessors() throws {
        let (_, props) = try propertiesOfSingleImage([
            WzFixtures.property("i", WzFixtures.int32(42)),
            WzFixtures.property("f", WzFixtures.float(9.9)),
            WzFixtures.property("d", WzFixtures.double(-8.0)),
            WzFixtures.property("num", WzFixtures.string("123")),
            WzFixtures.property("word", WzFixtures.string("abc")),
            WzFixtures.property("link", WzFixtures.uol("target/path")),
            WzFixtures.property("vec", WzFixtures.vector(x: 3, y: -7)),
            WzFixtures.property("i16", WzFixtures.int16(5)),
            WzFixtures.property("i64", WzFixtures.int64(9)),
        ])

        // intValue across numeric + numeric-string cases.
        XCTAssertEqual(props["i"]?.intValue, 42)
        XCTAssertEqual(props["f"]?.intValue, 9)
        XCTAssertEqual(props["d"]?.intValue, -8)
        XCTAssertEqual(props["i16"]?.intValue, 5)
        XCTAssertEqual(props["i64"]?.intValue, 9)
        XCTAssertEqual(props["num"]?.intValue, 123)
        XCTAssertNil(props["word"]?.intValue)       // non-numeric string
        XCTAssertNil(props["vec"]?.intValue)        // vector has no int value

        // stringValue for string and uol.
        XCTAssertEqual(props["word"]?.stringValue, "abc")
        XCTAssertEqual(props["link"]?.stringValue, "target/path")
        XCTAssertNil(props["i"]?.stringValue)

        // vectorValue.
        XCTAssertEqual(props["vec"]?.vectorValue?.x, 3)
        XCTAssertEqual(props["vec"]?.vectorValue?.y, -7)
        XCTAssertNil(props["i"]?.vectorValue)

        // canvas/sound accessors return nil for the wrong type.
        XCTAssertNil(props["i"]?.canvasValue)
        XCTAssertNil(props["i"]?.soundValue)

        // path helpers.
        XCTAssertEqual(props.int("i"), 42)
        XCTAssertEqual(props.string("word"), "abc")
        XCTAssertEqual(props.vector("vec")?.x, 3)
        XCTAssertNil(props.canvas("i"))
        XCTAssertNil(props.property(at: "missing"))
    }

    func testSubPropertyNestingAndPaths() throws {
        let inner = WzFixtures.sub([
            WzFixtures.property("child", WzFixtures.int32(7)),
            WzFixtures.property("deep", WzFixtures.sub([
                WzFixtures.property("leaf", WzFixtures.string("found")),
            ])),
        ])
        let (_, props) = try propertiesOfSingleImage([
            WzFixtures.property("info", inner),
        ])

        guard case .sub(let items) = props["info"] else { return XCTFail("sub") }
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(props["info"]?.children.count, 2)
        XCTAssertEqual(props.int("info/child"), 7)
        XCTAssertEqual(props.string("info/deep/leaf"), "found")
        // Descending through a non-existent middle component fails cleanly.
        XCTAssertNil(props.property(at: "info/nope/leaf"))
    }

    func testConvexChildrenAreIndexNamed() throws {
        let (_, props) = try propertiesOfSingleImage([
            WzFixtures.property("shape", WzFixtures.convex(points: [(1, 2), (3, 4), (5, 6)])),
        ])
        guard case .convex(let items) = props["shape"] else { return XCTFail("convex") }
        XCTAssertEqual(items.count, 3)
        let children = props["shape"]?.children ?? []
        XCTAssertEqual(children.map(\.name), ["0", "1", "2"])
        XCTAssertEqual(children["1"]?.vectorValue?.x, 3)
        XCTAssertEqual(children["1"]?.vectorValue?.y, 4)
    }

    func testChildrenOfScalarIsEmpty() throws {
        let (_, props) = try propertiesOfSingleImage([
            WzFixtures.property("i", WzFixtures.int32(1)),
        ])
        XCTAssertTrue(props["i"]?.children.isEmpty ?? false)
    }

    func testSoundExtractionAndData() throws {
        let audio: [UInt8] = Array("ID3-fake-mp3-bytes".utf8)
        let (archive, props) = try propertiesOfSingleImage([
            WzFixtures.property("clip", WzFixtures.sound(audio: audio, duration: 1500)),
        ])
        let sound = try XCTUnwrap(props["clip"]?.soundValue)
        XCTAssertEqual(sound.dataLength, audio.count)
        XCTAssertEqual(sound.durationMilliseconds, 1500)
        let data = try XCTUnwrap(archive.soundData(sound))
        XCTAssertEqual([UInt8](data), audio)
    }

    func testCanvasDecodeBGRA8888() throws {
        // One 2x1 BGRA8888 pixel row: pixel0 = B,G,R,A.
        let raw: [UInt8] = [10, 20, 30, 40,  50, 60, 70, 80]
        let (archive, props) = try propertiesOfSingleImage([
            WzFixtures.property("pic", WzFixtures.canvas(width: 2, height: 1, format: 2, rawPixels: raw,
                properties: [WzFixtures.property("origin", WzFixtures.vector(x: 1, y: 2))])),
        ])
        let canvas = try XCTUnwrap(props["pic"]?.canvasValue)
        XCTAssertEqual(canvas.width, 2)
        XCTAssertEqual(canvas.height, 1)
        XCTAssertEqual(canvas.format, 2)
        XCTAssertEqual(canvas.properties.vector("origin")?.x, 1)

        let bitmap = try archive.decodeCanvas(canvas)
        XCTAssertEqual(bitmap.width, 2)
        XCTAssertEqual(bitmap.height, 1)
        // BGRA8888 -> RGBA: R=raw[2], G=raw[1], B=raw[0], A=raw[3].
        XCTAssertEqual(Array(bitmap.rgba.prefix(4)), [30, 20, 10, 40])
        XCTAssertEqual(Array(bitmap.rgba.suffix(4)), [70, 60, 50, 80])
    }

    func testUnknownExtendedTypeParsesAsNull() throws {
        // An extended block with an unrecognized identifier becomes .null and the
        // reader seeks past it to the next entry.
        let mystery = WzFixtures.extended([0x73] + WzFixtures.wzString("Totally#Unknown") + [0xAB, 0xCD, 0xEF])
        let (_, props) = try propertiesOfSingleImage([
            WzFixtures.property("weird", mystery),
            WzFixtures.property("after", WzFixtures.int32(99)),
        ])
        guard case .null = props["weird"] else { return XCTFail("expected null for unknown extended") }
        XCTAssertEqual(props.int("after"), 99, "reader should resume at the next entry")
    }
}
