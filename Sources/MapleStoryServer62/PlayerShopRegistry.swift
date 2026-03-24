//
//  PlayerShopRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

// MARK: - Models

public struct PlayerShopItem: Equatable, Hashable, Sendable {
    public let itemID: UInt32
    public let slot: Int8
    public var bundles: UInt16
    public let pricePerBundle: UInt32

    public init(itemID: UInt32, slot: Int8, bundles: UInt16, pricePerBundle: UInt32) {
        self.itemID = itemID
        self.slot = slot
        self.bundles = bundles
        self.pricePerBundle = pricePerBundle
    }
}

public struct PlayerShop: Equatable, Hashable, Sendable {
    public let id: UInt32
    public let ownerID: Character.ID
    public let mapID: Map.ID
    public let description: String
    public var items: [PlayerShopItem]
    public var visitorIDs: [Character.ID]
    public var isOpen: Bool

    public init(id: UInt32, ownerID: Character.ID, mapID: Map.ID, description: String) {
        self.id = id
        self.ownerID = ownerID
        self.mapID = mapID
        self.description = description
        self.items = []
        self.visitorIDs = []
        self.isOpen = false
    }
}

public struct TradeItem: Equatable, Hashable, Sendable {
    public let itemID: UInt32
    public let quantity: UInt16
    public let slot: UInt8

    public init(itemID: UInt32, quantity: UInt16, slot: UInt8) {
        self.itemID = itemID
        self.quantity = quantity
        self.slot = slot
    }
}

public struct TradeSession: Equatable, Hashable, Sendable {
    public let id: UInt32
    public let initiatorID: Character.ID
    public var partnerID: Character.ID?
    public var initiatorItems: [TradeItem]
    public var partnerItems: [TradeItem]
    public var initiatorMeso: UInt32
    public var partnerMeso: UInt32
    public var initiatorConfirmed: Bool
    public var partnerConfirmed: Bool

    public init(id: UInt32, initiatorID: Character.ID) {
        self.id = id
        self.initiatorID = initiatorID
        self.partnerID = nil
        self.initiatorItems = []
        self.partnerItems = []
        self.initiatorMeso = 0
        self.partnerMeso = 0
        self.initiatorConfirmed = false
        self.partnerConfirmed = false
    }

    public var isComplete: Bool { initiatorConfirmed && partnerConfirmed }
}

// MARK: - Registry

public actor PlayerShopRegistry {

    public static let shared = PlayerShopRegistry()

    private var shops: [Character.ID: PlayerShop] = [:]
    private var trades: [Character.ID: TradeSession] = [:]
    private var nextID: UInt32 = 1

    private init() {}

    // MARK: - Player Shops

    @discardableResult
    public func createShop(ownerID: Character.ID, mapID: Map.ID, description: String) -> PlayerShop {
        let shop = PlayerShop(id: nextID, ownerID: ownerID, mapID: mapID, description: description)
        nextID += 1
        shops[ownerID] = shop
        return shop
    }

    public func shop(for ownerID: Character.ID) -> PlayerShop? {
        shops[ownerID]
    }

    public func shopVisiting(visitorID: Character.ID) -> PlayerShop? {
        shops.values.first { $0.visitorIDs.contains(visitorID) }
    }

    public func openShop(ownerID: Character.ID) {
        shops[ownerID]?.isOpen = true
    }

    public func addItem(_ item: PlayerShopItem, to ownerID: Character.ID) {
        shops[ownerID]?.items.append(item)
    }

    public func removeItem(slot: Int, from ownerID: Character.ID) -> PlayerShopItem? {
        guard var shop = shops[ownerID], slot < shop.items.count else { return nil }
        let removed = shop.items.remove(at: slot)
        shops[ownerID] = shop
        return removed
    }

    public func buyItem(slot: Int, quantity: UInt16, from ownerID: Character.ID) -> (item: PlayerShopItem, totalPrice: UInt32)? {
        guard var shop = shops[ownerID], slot < shop.items.count else { return nil }
        var item = shop.items[slot]
        let bundlesNeeded = UInt16((Int(quantity) + Int(item.bundles) - 1) / max(1, Int(item.bundles)))
        guard bundlesNeeded <= item.bundles else { return nil }
        let totalPrice = item.pricePerBundle * UInt32(bundlesNeeded)
        item.bundles -= bundlesNeeded
        if item.bundles == 0 {
            shop.items.remove(at: slot)
        } else {
            shop.items[slot] = item
        }
        shops[ownerID] = shop
        return (item, totalPrice)
    }

    public func addVisitor(_ visitorID: Character.ID, to ownerID: Character.ID) -> Bool {
        guard var shop = shops[ownerID], shop.isOpen, shop.visitorIDs.count < 3,
              !shop.visitorIDs.contains(visitorID) else { return false }
        shop.visitorIDs.append(visitorID)
        shops[ownerID] = shop
        return true
    }

    public func removeVisitor(_ visitorID: Character.ID) {
        for ownerID in shops.keys {
            shops[ownerID]?.visitorIDs.removeAll { $0 == visitorID }
        }
    }

    public func removeShop(ownerID: Character.ID) -> PlayerShop? {
        shops.removeValue(forKey: ownerID)
    }

    // MARK: - Trades

    @discardableResult
    public func createTrade(initiatorID: Character.ID) -> TradeSession {
        let session = TradeSession(id: nextID, initiatorID: initiatorID)
        nextID += 1
        trades[initiatorID] = session
        return session
    }

    public func trade(for characterID: Character.ID) -> TradeSession? {
        trades[characterID] ?? trades.values.first { $0.partnerID == characterID }
    }

    public func acceptTrade(partnerID: Character.ID, initiatorID: Character.ID) -> Bool {
        guard var session = trades[initiatorID] else { return false }
        session.partnerID = partnerID
        trades[initiatorID] = session
        trades[partnerID] = session   // mirror so partner can look up too
        return true
    }

    public func setMeso(_ meso: UInt32, for characterID: Character.ID) {
        updateTrade(for: characterID) { session, isInitiator in
            if isInitiator { session.initiatorMeso = meso } else { session.partnerMeso = meso }
        }
    }

    public func confirm(characterID: Character.ID) -> TradeSession? {
        updateTrade(for: characterID) { session, isInitiator in
            if isInitiator { session.initiatorConfirmed = true } else { session.partnerConfirmed = true }
        }
        return trade(for: characterID)
    }

    public func cancelTrade(characterID: Character.ID) {
        if let session = trade(for: characterID) {
            trades.removeValue(forKey: session.initiatorID)
            if let partnerID = session.partnerID {
                trades.removeValue(forKey: partnerID)
            }
        }
    }

    // MARK: - Helpers

    @discardableResult
    private func updateTrade(for characterID: Character.ID, update: (inout TradeSession, _ isInitiator: Bool) -> Void) -> Bool {
        if var session = trades[characterID] {
            update(&session, session.initiatorID == characterID)
            trades[session.initiatorID] = session
            if let partnerID = session.partnerID {
                trades[partnerID] = session
            }
            return true
        }
        return false
    }
}
