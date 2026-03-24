//
//  SummonAttackNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Sent when a summon attacks monsters
public struct SummonAttackNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .summonAttack }

    /// Character ID who owns the summon
    public let characterID: UInt32

    /// Summon object ID
    public let objectID: UInt32

    /// Number of monsters attacked
    public let numAttacked: UInt8

    public init(characterID: UInt32, objectID: UInt32, numAttacked: UInt8) {
        self.characterID = characterID
        self.objectID = objectID
        self.numAttacked = numAttacked
    }
}
