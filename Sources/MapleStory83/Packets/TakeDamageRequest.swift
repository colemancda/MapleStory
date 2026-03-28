//
//  TakeDamageRequest.swift
//

import Foundation

public struct TakeDamageRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .takeDamage }

    internal let value0: UInt32

    /// -2 = map damage, -1 = fall damage, otherwise monster objectID
    public let damageFrom: Int8

    internal let value1: UInt8

    public let damage: UInt32

    /// Source monster ID (0 if map/fall damage)
    public let monsterIDFrom: UInt32

    /// Source monster object ID
    public let monsterOID: UInt32

    public let direction: UInt8
}

extension TakeDamageRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.value0 = try container.decode(UInt32.self)
        self.damageFrom = try container.decode(Int8.self)
        self.value1 = try container.decode(UInt8.self)
        self.damage = try container.decode(UInt32.self)
        if container.remainingBytes >= 9 {
            self.monsterIDFrom = try container.decode(UInt32.self)
            self.monsterOID = try container.decode(UInt32.self)
            self.direction = try container.decode(UInt8.self)
        } else {
            self.monsterIDFrom = 0
            self.monsterOID = 0
            self.direction = 0
        }
    }
}
