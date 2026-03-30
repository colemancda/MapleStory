//
//  SpawnMonsterControl.swift
//

import Foundation

/// Sent to the controlling client for a mob.
public struct SpawnMonsterControl: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnMonsterControl }

    /// Control level: 2 = aggressive, 1 = passive, 0 = release.
    public let control: UInt8

    public let mob: MobSpawnData

    public init(control: UInt8 = 2, mob: MobSpawnData) {
        self.control = control
        self.mob = mob
    }
}

extension SpawnMonsterControl: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(control)
        try mob.encode(to: container)
    }
}
