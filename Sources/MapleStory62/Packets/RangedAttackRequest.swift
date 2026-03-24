//
//  RangedAttackRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct RangedAttackRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .rangedAttack }

    public let numAttackedAndDamage: UInt8

    public let skillID: UInt32

    public let stance: UInt8
}

extension RangedAttackRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        let _ = try container.decode(UInt8.self)
        self.numAttackedAndDamage = try container.decode(UInt8.self)
        self.skillID = try container.decode(UInt32.self)
        let _ = try container.decode(UInt8.self)
        self.stance = try container.decode(UInt8.self)
        // remaining attack target data is intentionally not parsed
    }
}
