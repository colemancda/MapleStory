//
//  MovementTests.swift
//  Round trip coverage for every Movement case.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStory28

final class MovementTests: XCTestCase {

    func testAbsolute() {
        let value = Movement.absolute(
            .init(command: 5, xpos: 100, ypos: 200, xwobble: 1, ywobble: 2, value0: 0, newState: 6, duration: 30)
        )
        assertValueRoundTrip28(value)
    }

    func testRelative() {
        let value = Movement.relative(
            .init(command: 1, xmod: 10, ymod: 20, newState: 3, duration: 40)
        )
        assertValueRoundTrip28(value)
    }

    func testTeleport() {
        let value = Movement.teleport(
            .init(command: 3, xpos: 50, ypos: 60, xwobble: 5, ywobble: 6, newState: 7)
        )
        assertValueRoundTrip28(value)
    }

    func testChangeEquipment() {
        let value = Movement.changeEquipment(
            .init(command: 10, wui: 1)
        )
        assertValueRoundTrip28(value)
    }

    func testChair() {
        let value = Movement.chair(
            .init(command: 11, xpos: 70, ypos: 80, value0: 0, newState: 2, duration: 15)
        )
        assertValueRoundTrip28(value)
    }

    func testJumpDown() {
        let value = Movement.jumpDown(
            .init(command: 15, xpos: 90, ypos: 100, xwobble: 3, ywobble: 4, value0: 0, fh: 5, newState: 6, duration: 25)
        )
        assertValueRoundTrip28(value)
    }

    func testInvalidCommandThrows() {
        var decoder = MapleStoryDecoder()
        decoder.log = { print("Decoder:", $0) }
        XCTAssertThrowsError(try decoder.decode(Movement.self, from: Data([100])))
    }
}
