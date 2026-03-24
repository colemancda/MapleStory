//
//  DamageSummonRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct DamageSummonRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .damageSummon }

    internal let value0: UInt32

    public let unkByte: UInt8

    public let damage: UInt32

    public let monsterIDFrom: UInt32

    public let stance: UInt8
}
