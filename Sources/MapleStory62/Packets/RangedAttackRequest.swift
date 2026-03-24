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

    /// Per-target damage. Key = monster object ID, value = list of damage values for that target.
    public let targets: [UInt32: [UInt32]]

    public var numTargets: Int { Int(numAttackedAndDamage >> 4) }
    public var numDamagePerTarget: Int { Int(numAttackedAndDamage & 0xF) }
}

extension RangedAttackRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        let _ = try container.decode(UInt8.self)
        self.numAttackedAndDamage = try container.decode(UInt8.self)
        self.skillID = try container.decode(UInt32.self)
        let _ = try container.decode(UInt8.self)
        self.stance = try container.decode(UInt8.self)

        let nTargets = Int(numAttackedAndDamage >> 4)
        let nDamage  = Int(numAttackedAndDamage & 0xF)
        var targets: [UInt32: [UInt32]] = [:]
        for _ in 0 ..< nTargets {
            guard container.remainingBytes >= 4 + nDamage * 4 else { break }
            let objectID = try container.decode(UInt32.self)
            var damages: [UInt32] = []
            for _ in 0 ..< nDamage {
                damages.append(try container.decode(UInt32.self))
            }
            targets[objectID] = damages
        }
        self.targets = targets
    }
}
