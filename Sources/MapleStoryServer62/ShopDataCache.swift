//
//  ShopDataCache.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Shop item data
public struct ShopItem: Codable, Equatable, Hashable, Sendable {

    /// Item template ID
    public let itemID: UInt32

    /// Price in mesos (0 = cannot be bought, only sold)
    public let price: UInt32

    /// Stock (0 = infinite, -1 = out of stock, >0 = remaining stock)
    public let stock: Int32

    /// Recharge item?
    public let isRecharge: Bool

    /// Create shop item
    public init(itemID: UInt32, price: UInt32, stock: Int32 = 0, isRecharge: Bool = false) {
        self.itemID = itemID
        self.price = price
        self.stock = stock
        self.isRecharge = isRecharge
    }
}

/// NPC Shop data
public struct NPCShop: Codable, Equatable, Hashable, Sendable {

    /// Shop ID (typically NPC ID)
    public let npcID: UInt32

    /// Items sold by this shop
    public let items: [ShopItem]

    /// Create shop data
    public init(npcID: UInt32, items: [ShopItem]) {
        self.npcID = npcID
        self.items = items
    }
}

/// In-memory cache of NPC shop data.
public actor ShopDataCache {

    public static let shared = ShopDataCache()

    private var shops: [UInt32: NPCShop] = [:]

    private init() {}

    /// Register a shop for an NPC.
    public func registerShop(_ shop: NPCShop) {
        shops[shop.npcID] = shop
    }

    /// Get shop data for an NPC.
    public func shop(npcID: UInt32) -> NPCShop? {
        shops[npcID]
    }

    /// Get shop item price.
    public func price(itemID: UInt32, npcID: UInt32) -> UInt32? {
        guard let shop = shops[npcID] else { return nil }
        return shop.items.first { $0.itemID == itemID }?.price
    }

    /// Check if an item is rechargeable.
    public func isRechargeItem(itemID: UInt32, npcID: UInt32) -> Bool {
        guard let shop = shops[npcID] else { return false }
        return shop.items.contains { $0.itemID == itemID && $0.isRecharge }
    }

    /// Number of registered shops.
    public var count: Int { shops.count }
}
