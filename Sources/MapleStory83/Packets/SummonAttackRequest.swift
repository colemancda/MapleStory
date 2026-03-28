//
//  SummonAttackRequest.swift
//

import Foundation

public struct SummonAttackRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .summonAttack }

    public let objectID: UInt32
    public let numAttacked: UInt8
}

extension SummonAttackRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        let _ = try container.decode(UInt32.self)
        self.objectID = try container.decode(UInt32.self)
        self.numAttacked = try container.decode(UInt8.self)
        // per-monster damage data is intentionally not parsed
    }
}
