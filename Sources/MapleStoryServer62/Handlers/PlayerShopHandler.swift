//
//  PlayerShopHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct PlayerShopHandler: PacketHandler {

    public typealias Packet = MapleStory62.PlayerShopRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        switch packet {

        // MARK: - Create

        case .createTrade:
            await PlayerShopRegistry.shared.createTrade(initiatorID: character.id)
            try await connection.send(ServerMessageNotification.notice(message: "Trade started."))

        case let .createShop(description):
            await PlayerShopRegistry.shared.createShop(
                ownerID: character.id,
                mapID: character.currentMap,
                description: description
            )
            try await connection.send(ServerMessageNotification.notice(message: "Player shop created."))

        case .createOmok, .createMatchCard:
            // Mini-game creation — not yet implemented
            break

        // MARK: - Session management

        case let .invite(targetID):
            _ = targetID
            try await connection.send(ServerMessageNotification.notice(
                message: "Trade invite recorded. Cross-player dispatch is not wired yet."
            ))

        case .decline:
            await PlayerShopRegistry.shared.cancelTrade(characterID: character.id)

        case let .visit(objectID):
            if let shop = await PlayerShopRegistry.shared.shop(forObjectID: objectID) {
                guard shop.mapID == character.currentMap else { return }
                guard await PlayerShopRegistry.shared.addVisitor(character.id, to: shop.ownerID) else { return }
                try await connection.send(ServerMessageNotification.notice(message: "Entered player shop."))
                return
            }

            if let trade = await PlayerShopRegistry.shared.trade(sessionID: objectID) {
                guard trade.partnerID == nil else { return }
                guard await PlayerShopRegistry.shared.acceptTrade(partnerID: character.id, initiatorID: trade.initiatorID) else { return }
                try await connection.send(ServerMessageNotification.notice(message: "Joined trade session."))
            }

        case let .chat(message):
            let notification = ChatTextNotification(
                characterID: character.index,
                isAdmin: false,
                message: message,
                show: true
            )
            try await connection.broadcast(notification, map: character.currentMap)

        case .exit:
            // Check if in a trade
            if let trade = await PlayerShopRegistry.shared.trade(for: character.id) {
                await PlayerShopRegistry.shared.cancelTrade(characterID: character.id)
                _ = trade
                // TODO: Return items to initiator's inventory if cancelling as owner
            } else if let shop = await PlayerShopRegistry.shared.shop(for: character.id) {
                // Owner closing shop: return unsold items
                let items = shop.items
                _ = await PlayerShopRegistry.shared.removeShop(ownerID: character.id)
                _ = items
                // TODO: Add items back to inventory via InventoryManipulator
            } else {
                // Visitor leaving shop
                await PlayerShopRegistry.shared.removeVisitor(character.id)
            }

        case .open:
            await PlayerShopRegistry.shared.openShop(ownerID: character.id)
            try await connection.send(ServerMessageNotification.notice(message: "Shop is now open."))

        // MARK: - Trade

        case let .setMeso(amount):
            await PlayerShopRegistry.shared.setMeso(amount, for: character.id)

        case let .setItems(inventoryType, slot, quantity, targetSlot):
            guard await PlayerShopRegistry.shared.trade(for: character.id) != nil else { return }
            guard let invType = InventoryType(rawValue: inventoryType) else { return }
            guard quantity > 0 else { return }
            let inventorySlot = Int8(clamping: Int(slot))
            guard inventorySlot > 0 else { return }

            let inventory = await character.getInventory()
            guard let item = inventory[invType][inventorySlot], item.quantity >= UInt16(quantity) else { return }

            let tradeItem = TradeItem(
                itemID: item.itemId,
                quantity: UInt16(quantity),
                slot: UInt8(clamping: inventorySlot),
                targetSlot: targetSlot
            )
            await PlayerShopRegistry.shared.setTradeItem(tradeItem, for: character.id)
            try await connection.send(ServerMessageNotification.notice(message: "Trade item updated."))

        case .confirm:
            if let session = await PlayerShopRegistry.shared.confirm(characterID: character.id),
               session.isComplete {
                await PlayerShopRegistry.shared.cancelTrade(characterID: character.id)
                try await connection.send(ServerMessageNotification.notice(
                    message: "Trade confirmed."
                ))
            }

        // MARK: - Shop

        case let .addItem(inventoryType, slot, bundles, perBundle, price):
            guard let shop = await PlayerShopRegistry.shared.shop(for: character.id),
                  !shop.isOpen else { return }
            guard bundles > 0, perBundle > 0 else { return }
            guard let invType = InventoryType(rawValue: inventoryType) else { return }

            var inventory = await character.getInventory()
            guard var item = inventory[invType][slot] else { return }
            let requiredQuantity = UInt32(Int32(bundles)) * UInt32(Int32(perBundle))
            guard requiredQuantity > 0,
                  requiredQuantity <= UInt32(item.quantity) else { return }
            let required = UInt16(requiredQuantity)

            if item.quantity == required {
                inventory[invType][slot] = nil
            } else {
                item.quantity -= required
                inventory[invType][slot] = item
            }
            await character.setInventory(inventory)

            let shopItem = PlayerShopItem(
                itemID: item.itemId,
                slot: slot,
                bundles: UInt16(bundles),
                quantityPerBundle: UInt16(perBundle),
                pricePerBundle: price
            )
            await PlayerShopRegistry.shared.addItem(shopItem, to: character.id)
            try await connection.send(ServerMessageNotification.notice(message: "Shop item added."))

        case let .removeItem(slot):
            guard let shop = await PlayerShopRegistry.shared.shop(for: character.id) else { return }
            guard Int(slot) >= 0, Int(slot) < shop.items.count else { return }
            let candidate = shop.items[Int(slot)]
            guard let inventoryType = await ItemDataCache.shared.inventoryType(for: candidate.itemID) else { return }

            var inventory = await character.getInventory()
            guard let emptySlot = inventory.findEmptySlot(in: inventoryType) else { return }
            guard let removed = await PlayerShopRegistry.shared.removeItem(slot: Int(slot), from: character.id) else { return }

            let quantity = removed.bundles * removed.quantityPerBundle
            let restored = InventoryItem(
                itemId: removed.itemID,
                slot: emptySlot,
                quantity: quantity
            )
            inventory[inventoryType][emptySlot] = restored
            await character.setInventory(inventory)
            try await connection.send(ServerMessageNotification.notice(message: "Shop item removed."))

        case let .buy(slot, quantity):
            guard let visitedShop = await PlayerShopRegistry.shared.shopVisiting(visitorID: character.id) else { return }
            guard quantity > 0 else { return }
            guard Int(slot) < visitedShop.items.count else { return }
            let preflightItem = visitedShop.items[Int(slot)]
            let preflightPrice = preflightItem.pricePerBundle * UInt32(quantity)
            guard character.meso >= preflightPrice else { return }
            if let (item, totalPrice) = await PlayerShopRegistry.shared.buyItem(
                slot: Int(slot),
                quantity: UInt16(quantity),
                from: visitedShop.ownerID
            ) {
                guard character.meso >= totalPrice else { return }
                let addedQuantity = item.quantityPerBundle * UInt16(quantity)
                guard let addedSlot = try await InventoryManipulator().addById(
                    item.itemID,
                    quantity: addedQuantity,
                    to: character
                ) else { return }
                _ = addedSlot

                character.meso -= totalPrice
                try await connection.database.insert(character)
                try await connection.send(ServerMessageNotification.notice(message: "Purchase completed."))
            }

        // MARK: - Mini-game (stubs — requires dedicated mini-game state)

        case .ready, .unready, .start, .giveUp,
             .requestTie, .answerTie, .skip,
             .moveOmok, .selectCard,
             .exitAfterGame, .cancelExit:
            // Mini-game operations — not yet implemented
            break
        }
    }
}
