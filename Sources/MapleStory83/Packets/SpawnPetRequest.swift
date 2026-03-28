//
//  SpawnPetRequest.swift
//

import Foundation

public struct SpawnPetRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .spawnPet }

    internal let value0: UInt32

    public let slot: UInt8

    internal let value1: UInt8

    /// Whether this pet is the lead pet
    public let isLead: UInt8
}

extension SpawnPetRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.value0 = try container.decode(UInt32.self)
        self.slot = try container.decode(UInt8.self)
        self.value1 = try container.decode(UInt8.self)
        self.isLead = try container.decode(UInt8.self)
    }
}
