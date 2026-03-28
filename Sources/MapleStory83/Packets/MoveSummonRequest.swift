//
//  MoveSummonRequest.swift
//

import Foundation

public struct MoveSummonRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .moveSummon }

    public let objectID: UInt32
    public let startX: Int16
    public let startY: Int16
}

extension MoveSummonRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.objectID = try container.decode(UInt32.self)
        self.startX = try container.decode(Int16.self)
        self.startY = try container.decode(Int16.self)
        // movement data is intentionally not parsed
    }
}
