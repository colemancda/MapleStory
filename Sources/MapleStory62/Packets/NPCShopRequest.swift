//
//  NPCShopRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct NPCShopRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .npcShop }

    /// 0 = buy, 1 = sell, 2 = recharge
    public let mode: UInt8

    public let itemID: UInt32?

    public let slot: Int16?

    public let quantity: Int16?
}

extension NPCShopRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.mode = try container.decode(UInt8.self)
        switch mode {
        case 0: // buy
            self.slot = try container.decode(Int16.self)
            self.itemID = try container.decode(UInt32.self)
            self.quantity = try container.decode(Int16.self)
        case 1: // sell
            self.slot = try container.decode(Int16.self)
            self.itemID = try container.decode(UInt32.self)
            self.quantity = try container.decode(Int16.self)
        case 2: // recharge
            self.slot = try container.decode(Int16.self)
            self.itemID = nil
            self.quantity = nil
        default:
            self.slot = nil
            self.itemID = nil
            self.quantity = nil
        }
    }
}
