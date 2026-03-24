//
//  SpawnMonsterNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

// MARK: - Shared Mob Spawn Data

/// Mob data shared by both spawn packet types.
public struct MobSpawnData: Codable, Equatable, Hashable, Sendable {
    public let objectID: UInt32
    public let mobID: UInt32
    public let x: Int16
    public let y: Int16
    public let foothold: UInt16
    public let rx0: Int16
    public let rx1: Int16
    /// 1 = face left, 0 = face right.
    public let facing: UInt8

    public init(
        objectID: UInt32,
        mobID: UInt32,
        x: Int16,
        y: Int16,
        foothold: UInt16,
        rx0: Int16,
        rx1: Int16,
        facing: UInt8
    ) {
        self.objectID = objectID
        self.mobID = mobID
        self.x = x
        self.y = y
        self.foothold = foothold
        self.rx0 = rx0
        self.rx1 = rx1
        self.facing = facing
    }
}

extension MobSpawnData {

    func encode(to container: MapleStoryEncodingContainer, isController: Bool) throws {
        try container.encode(objectID)
        try container.encode(UInt8(0))           // controller flag: 0 for plain spawn
        try container.encode(mobID)
        try container.encode(UInt8(0))           // status bytes (simplified)
        try container.encode(x)
        try container.encode(y)
        try container.encode(UInt8(0))           // unknown
        try container.encode(foothold)
        try container.encode(rx0)
        try container.encode(rx1)
        try container.encode(facing)
        try container.encode(UInt8(0))           // unknown
        try container.encode(Int16(-1))          // HP bar time (-1 = show bar)
    }
}

// MARK: - SpawnMonsterNotification (0xAF)

/// Sent to clients on a map when a mob appears (player enters or mob respawns).
/// The controlling client receives `SpawnMonsterControl` instead.
public struct SpawnMonsterNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnMonster }

    public let mob: MobSpawnData

    public init(mob: MobSpawnData) {
        self.mob = mob
    }
}

extension SpawnMonsterNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try mob.encode(to: container, isController: false)
    }
}
