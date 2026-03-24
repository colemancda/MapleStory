//
//  WzMap.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation

/// Map data parsed from a `Map.wz/Map/MapX/<id>.img.xml` file.
public struct WzMap: Equatable, Sendable {

    public let id: UInt32

    // MARK: Info

    public struct Info: Equatable, Sendable {
        public let returnMap: UInt32
        public let forcedReturn: UInt32
        public let mobRate: Float
        public let bgm: String
        public let mapMark: String
        public let isTown: Bool
        public let cloud: Bool
        public let hideMinimap: Bool
        public let moveLimit: Bool
        public let fieldType: Int32
    }
    public let info: Info

    // MARK: Portal

    public struct Portal: Equatable, Sendable {
        /// Portal name (e.g. `"sp"`, `"warp"`).
        public let name: String
        /// Portal type (0 = spawn, 2 = normal portal, etc.).
        public let type: Int32
        public let x: Int32
        public let y: Int32
        /// Target map ID.
        public let targetMap: UInt32
        /// Target portal name in destination map.
        public let targetName: String
    }
    public let portals: [Portal]

    // MARK: Foothold

    public struct Foothold: Equatable, Sendable {
        public let id: Int32
        public let x1: Int32
        public let y1: Int32
        public let x2: Int32
        public let y2: Int32
        public let prev: Int32
        public let next: Int32
    }
    public let footholds: [Foothold]

    // MARK: Life

    public enum LifeType: String, Equatable, Sendable {
        case npc = "n"
        case mob = "m"
    }
    public struct Life: Equatable, Sendable {
        public let type: LifeType
        /// NPC or mob ID string.
        public let id: String
        public let x: Int32
        public let y: Int32
        /// Foothold ID the life stands on.
        public let foothold: Int32
        /// Vertical center position.
        public let cy: Int32
        /// Roam range left.
        public let rx0: Int32
        /// Roam range right.
        public let rx1: Int32
        /// Respawn time in seconds (mobs only).
        public let mobTime: Int32
        /// Facing direction (0 = right, 1 = left).
        public let facing: Int32
        public let hide: Bool
    }
    public let life: [Life]
}

// MARK: - Parsing

public extension WzMap {

    init(id: UInt32, node: WzNode) throws {
        self.id = id

        guard let infoNode = node["info"] else {
            throw WzParseError.missingAttribute("info", element: node.name)
        }
        func int(_ n: WzNode, _ key: String, default def: Int32 = 0) -> Int32 {
            n[key]?.intValue ?? def
        }
        func uint(_ n: WzNode, _ key: String, default def: UInt32 = 999_999_999) -> UInt32 {
            guard let v = n[key]?.intValue else { return def }
            return UInt32(bitPattern: v)
        }
        self.info = Info(
            returnMap:     uint(infoNode, "returnMap"),
            forcedReturn:  uint(infoNode, "forcedReturn"),
            mobRate:       infoNode["mobRate"]?.floatValue ?? 1.0,
            bgm:           infoNode["bgm"]?.stringValue ?? "",
            mapMark:       infoNode["mapMark"]?.stringValue ?? "",
            isTown:        int(infoNode, "town") != 0,
            cloud:         int(infoNode, "cloud") != 0,
            hideMinimap:   int(infoNode, "hideMinimap") != 0,
            moveLimit:     int(infoNode, "moveLimit") != 0,
            fieldType:     int(infoNode, "fieldType")
        )

        // Portals
        self.portals = (node["portal"]?.children ?? []).compactMap { child in
            guard
                let pn = child["pn"]?.stringValue,
                let pt = child["pt"]?.intValue,
                let x  = child["x"]?.intValue,
                let y  = child["y"]?.intValue
            else { return nil }
            let tm = uint(child, "tm")
            let tn = child["tn"]?.stringValue ?? ""
            return Portal(name: pn, type: pt, x: x, y: y, targetMap: tm, targetName: tn)
        }

        // Footholds — nested 3 levels: layer > group > foothold
        var fhs: [Foothold] = []
        for layerNode in (node["foothold"]?.children ?? []) {
            for groupNode in layerNode.children {
                for fhNode in groupNode.children {
                    guard let id = Int32(fhNode.name) else { continue }
                    fhs.append(Foothold(
                        id:   id,
                        x1:   int(fhNode, "x1"),
                        y1:   int(fhNode, "y1"),
                        x2:   int(fhNode, "x2"),
                        y2:   int(fhNode, "y2"),
                        prev: int(fhNode, "prev"),
                        next: int(fhNode, "next")
                    ))
                }
            }
        }
        self.footholds = fhs

        // Life spawns
        self.life = (node["life"]?.children ?? []).compactMap { child in
            guard
                let typeStr = child["type"]?.stringValue,
                let lifeType = LifeType(rawValue: typeStr),
                let id = child["id"]?.stringValue
            else { return nil }
            return Life(
                type:     lifeType,
                id:       id,
                x:        int(child, "x"),
                y:        int(child, "y"),
                foothold: int(child, "fh"),
                cy:       int(child, "cy"),
                rx0:      int(child, "rx0"),
                rx1:      int(child, "rx1"),
                mobTime:  int(child, "mobTime"),
                facing:   int(child, "f"),
                hide:     int(child, "hide") != 0
            )
        }
    }

    init(contentsOf url: URL) throws {
        let filename = url.deletingPathExtension().deletingPathExtension().lastPathComponent
        guard let id = UInt32(filename) else {
            throw WzParseError.invalidValue(filename, attribute: "filename")
        }
        let node = try WzXMLParser().parse(contentsOf: url)
        try self.init(id: id, node: node)
    }
}
