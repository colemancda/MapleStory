//
//  OpenNPCShopNotification.swift
//

import Foundation

/// Opens an NPC shop window on the client.
///
public struct OpenNPCShopNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .openNPCShop }

    public let shopID: UInt32

    public let items: [ShopItem]

    public struct ShopItem: Codable, Equatable, Hashable, Sendable {

        public let itemID: UInt32

        public let price: UInt32

        public let pitch: UInt32

        public let unknown1: UInt32

        public let unknown2: UInt32

        /// 0 for rechargeable items, 1 otherwise.
        public let stackSize: UInt16

        /// buyable count or max slot for rechargeable items.
        public let buyable: UInt16
    }
}
