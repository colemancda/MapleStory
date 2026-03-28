//
//  CashShopOperationRequest.swift
//

import Foundation

public struct CashShopOperationRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .cashshopOperation }

    /// Purchase method
    public let way: UInt8

    /// Cash shop item serial number
    public let snCS: UInt32
}

extension CashShopOperationRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        let _ = try container.decode(UInt8.self)
        self.way = try container.decode(UInt8.self)
        let _ = try container.decode(UInt8.self)
        let _ = try container.decode(UInt8.self)
        let _ = try container.decode(UInt8.self)
        self.snCS = try container.decode(UInt32.self)
    }
}
