//
//  CameraTests.swift
//  MapleStoryClientTests
//

import XCTest
@testable import MapleStoryClient

final class CameraTests: XCTestCase {

    func testCameraCentersOnItsPosition() {
        let camera = Camera(x: 100, y: 100, viewportWidth: 800, viewportHeight: 600)
        let center = camera.screen(forWorldX: 100, worldY: 100)
        XCTAssertEqual(center.x, 400, accuracy: 0.001)
        XCTAssertEqual(center.y, 300, accuracy: 0.001)
    }

    func testCameraOffsetsOtherPoints() {
        let camera = Camera(x: 100, y: 100, viewportWidth: 800, viewportHeight: 600)
        let origin = camera.screen(forWorldX: 0, worldY: 0)
        XCTAssertEqual(origin.x, 300, accuracy: 0.001)
        XCTAssertEqual(origin.y, 200, accuracy: 0.001)
    }

    func testScreenRectPreservesSize() {
        let camera = Camera(x: 0, y: 0, viewportWidth: 640, viewportHeight: 480)
        let rect = camera.screenRect(worldX: 10, worldY: 20, width: 32, height: 48)
        XCTAssertEqual(rect.x, 10 + 320, accuracy: 0.001)
        XCTAssertEqual(rect.y, 20 + 240, accuracy: 0.001)
        XCTAssertEqual(rect.width, 32, accuracy: 0.001)
        XCTAssertEqual(rect.height, 48, accuracy: 0.001)
    }
}
