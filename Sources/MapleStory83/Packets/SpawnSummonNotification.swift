//
//  SpawnSummonNotification.swift
//

import Foundation

/// Spawns a summon (special map object) for nearby clients.
///
public struct SpawnSummonNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnSpecialMapobject }

    public let ownerCharacterID: UInt32

    public let summonObjectID: UInt32

    public let skillID: UInt32

    public let unknown: UInt8

    public let skillLevel: UInt8

    public let x: Int16

    public let y: Int16

    public let stance: UInt8

    public let unknown2: UInt16

    /// 0=no movement, 1=follow, 2/4=teleport-follow, 3=bird-follow.
    public let movementType: UInt8

    public let canAttack: Bool

    public let isNotAnimated: Bool
}
