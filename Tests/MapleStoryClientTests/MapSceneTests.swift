//
//  MapSceneTests.swift
//  MapleStoryClientTests
//
//  GL-free MapScene behavior: input handling and portal entry (textures are
//  only created on first render, which these tests never trigger).
//

import XCTest
@testable import MapleStoryFile
@testable import MapleStoryClient

final class MapSceneTests: XCTestCase {

    private func makeMap(portals: [WzMapPortal]) -> WzLoadedMap {
        let ground = WzFoothold(id: 1, layer: 0, x1: -500, y1: 100, x2: 500, y2: 100, previousID: 0, nextID: 0)
        return WzLoadedMap(id: 1, backgrounds: [], foregrounds: [], tiles: [], objects: [],
                           left: -500, top: -500, right: 500, bottom: 500,
                           spawnX: 0, spawnY: 100, footholds: [ground], life: [],
                           portals: portals)
    }

    func testUpArrowEntersOverlappingPortal() {
        let portal = WzMapPortal(name: "east00", type: 2, x: 10, y: 100,
                                 targetMap: 100010000, targetName: "west00")
        let scene = MapScene(map: makeMap(portals: [portal]), playerStart: (0, 100))

        var entered: WzMapPortal?
        scene.onEnterPortal = { entered = $0 }
        scene.handle(.control(.up))

        XCTAssertEqual(entered?.targetMap, 100010000)
        XCTAssertEqual(entered?.targetName, "west00")
    }

    func testUpArrowIgnoresDistantAndSpawnPortals() {
        let distant = WzMapPortal(name: "far", type: 2, x: 400, y: 100,
                                  targetMap: 100010000, targetName: "west00")
        let spawn = WzMapPortal(name: "sp", type: 0, x: 0, y: 100,
                                targetMap: 999_999_999, targetName: "")
        let scene = MapScene(map: makeMap(portals: [distant, spawn]), playerStart: (0, 100))

        var entered: WzMapPortal?
        scene.onEnterPortal = { entered = $0 }
        scene.handle(.control(.up))

        XCTAssertNil(entered)
    }
}
