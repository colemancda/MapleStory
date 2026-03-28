//
//  MovePetRequest.swift
//

import Foundation

public struct MovePetRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .movePet }

    public let petID: UInt32
    public let startX: Int16
    public let startY: Int16
}

extension MovePetRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.petID = try container.decode(UInt32.self)
        let _ = try container.decode(UInt32.self)
        self.startX = try container.decode(Int16.self)
        self.startY = try container.decode(Int16.self)
        // movement data is intentionally not parsed
    }
}
