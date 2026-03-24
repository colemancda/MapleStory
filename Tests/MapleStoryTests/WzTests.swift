//
//  WzTests.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation
import XCTest
@testable import MapleStory

final class WzTests: XCTestCase {

    // MARK: - Parser

    func testParseDirectory() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <imgdir name="root">
            <int name="count" value="3"/>
            <string name="label" value="hello"/>
            <float name="rate" value="1.5"/>
            <imgdir name="child">
                <int name="x" value="99"/>
            </imgdir>
        </imgdir>
        """.data(using: .utf8)!

        let node = try WzXMLParser().parse(xml)
        XCTAssertEqual(node.name, "root")
        XCTAssertEqual(node["count"]?.intValue, 3)
        XCTAssertEqual(node["label"]?.stringValue, "hello")
        XCTAssertEqual(node["rate"]?.floatValue, 1.5)
        XCTAssertEqual(node.child(at: "child/x")?.intValue, 99)
    }

    func testParseVector() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <imgdir name="root">
            <vector name="origin" x="18" y="26"/>
        </imgdir>
        """.data(using: .utf8)!

        let node = try WzXMLParser().parse(xml)
        XCTAssertEqual(node["origin"]?.vectorX, 18)
        XCTAssertEqual(node["origin"]?.vectorY, 26)
    }

    func testParseCanvas() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <imgdir name="root">
            <canvas name="frame0" width="37" height="26">
                <vector name="origin" x="18" y="26"/>
                <int name="delay" value="180"/>
            </canvas>
        </imgdir>
        """.data(using: .utf8)!

        let node = try WzXMLParser().parse(xml)
        let frame = try XCTUnwrap(node["frame0"])
        if case .canvas(let w, let h, let children) = frame.value {
            XCTAssertEqual(w, 37)
            XCTAssertEqual(h, 26)
            XCTAssertEqual(children.count, 2)
        } else {
            XCTFail("Expected canvas")
        }
    }

    func testParseNull() throws {
        let xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <imgdir name="root">
            <null name="placeholder"/>
        </imgdir>
        """.data(using: .utf8)!

        let node = try WzXMLParser().parse(xml)
        let child = try XCTUnwrap(node["placeholder"])
        XCTAssertEqual(child.value, .null)
    }

    // MARK: - WzMob

    func testParseMobFile() throws {
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "0100100.img", withExtension: "xml", subdirectory: "Resources/Wz/Mob")
        )
        let mob = try WzMob(contentsOf: url)
        XCTAssertEqual(mob.id, 100100)
        XCTAssertEqual(mob.maxHP, 8)
        XCTAssertEqual(mob.maxMP, 0)
        XCTAssertEqual(mob.exp, 3)
        XCTAssertEqual(mob.level, 1)
        XCTAssertEqual(mob.paDamage, 12)
        XCTAssertEqual(mob.speed, -65)
        XCTAssertFalse(mob.isUndead)
        XCTAssertTrue(mob.isPushed)
        XCTAssertTrue(mob.bodyAttack)
    }
}
