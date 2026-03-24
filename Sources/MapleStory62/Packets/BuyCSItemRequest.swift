//
//  BuyCSItemRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct BuyCSItemRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .buyCSItem }

    /// Purchase method
    public let way: UInt8

    /// Cash shop item serial number
    public let snCS: UInt32
}

extension BuyCSItemRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        let _ = try container.decode(UInt8.self)
        self.way = try container.decode(UInt8.self)
        let _ = try container.decode(UInt8.self)
        let _ = try container.decode(UInt8.self)
        let _ = try container.decode(UInt8.self)
        self.snCS = try container.decode(UInt32.self)
    }
}
