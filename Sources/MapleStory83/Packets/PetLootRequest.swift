//
//  PetLootRequest.swift
//

import Foundation

public struct PetLootRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .petLoot }

    public let petID: UInt32

    public let objectID: UInt32
}

extension PetLootRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.petID = try container.decode(UInt32.self)
        for _ in 0 ..< 13 {
            let _ = try container.decode(UInt8.self)
        }
        self.objectID = try container.decode(UInt32.self)
    }
}
