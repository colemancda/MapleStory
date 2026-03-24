//
//  OpenNPCShopNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Notifies client to open NPC shop UI
public struct OpenNPCShopNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .openNPCShop }

    /// NPC ID
    public let npcID: UInt32

    /// Items sold by this shop
    public let items: [ShopItemEntry]

    /// Create shop notification
    public init(npcID: UInt32, items: [ShopItemEntry]) {
        self.npcID = npcID
        self.items = items
    }
}

/// Shop item entry for client display
public struct ShopItemEntry: Codable, Equatable, Hashable, Sendable {

    /// Item template ID
    public let itemID: UInt32

    /// Price in mesos
    public let price: UInt32

    /// Remaining stock (0 = infinite)
    public let stock: Int16

    /// Create shop item entry
    public init(itemID: UInt32, price: UInt32, stock: Int16 = 0) {
        self.itemID = itemID
        self.price = price
        self.stock = stock
    }
}
