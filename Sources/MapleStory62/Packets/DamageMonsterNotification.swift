//
//  DamageMonsterNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Broadcast to all clients on a map when a monster takes damage.
/// Opcode: `damageMonster` (0xB9)
public struct DamageMonsterNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .damageMonster }

    /// Monster map object ID.
    public let objectID: UInt32

    /// Damage type: 0 = normal, 1 = poison, 2 = burn.
    public let damageType: UInt8

    /// Damage dealt.
    public let damage: UInt32

    public init(objectID: UInt32, damageType: UInt8 = 0, damage: UInt32) {
        self.objectID = objectID
        self.damageType = damageType
        self.damage = damage
    }
}

extension DamageMonsterNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(objectID)
        try container.encode(damageType)
        try container.encode(damage)
    }
}
