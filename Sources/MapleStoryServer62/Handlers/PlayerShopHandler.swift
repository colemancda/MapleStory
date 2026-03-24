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
        guard let character = try await connection.character else { return }

        switch packet {

        // MARK: - Create

        case .createTrade:
            await PlayerShopRegistry.shared.createTrade(initiatorID: character.id)
            // TODO: Send PLAYER_INTERACTION open trade packet to client

        case let .createShop(description):
            await PlayerShopRegistry.shared.createShop(
                ownerID: character.id,
                mapID: character.currentMap,
                description: description
            )
            // TODO: Send PLAYER_INTERACTION open shop packet to client

        case .createOmok, .createMatchCard:
            // Mini-game creation — not yet implemented
            break

        // MARK: - Session management

        case let .invite(targetID):
            // Trade invite — would need to send packet to target player
            // TODO: Implement cross-player notification via server send API
            _ = targetID

        case .decline:
            await PlayerShopRegistry.shared.cancelTrade(characterID: character.id)

        case let .visit(objectID):
            // Visitor joins a shop or mini-game by map object ID
            // TODO: Look up shop by map object ID from map registry
            _ = objectID

        case let .chat(message):
            // Chat within a shop or trade session — not yet implemented
            _ = message

        case .exit:
            // Check if in a trade
            if let trade = await PlayerShopRegistry.shared.trade(for: character.id) {
                await PlayerShopRegistry.shared.cancelTrade(characterID: character.id)
                _ = trade
                // TODO: Return items to initiator's inventory if cancelling as owner
            } else if let shop = await PlayerShopRegistry.shared.shop(for: character.id) {
                // Owner closing shop: return unsold items
                let items = shop.items
                await PlayerShopRegistry.shared.removeShop(ownerID: character.id)
                _ = items
                // TODO: Add items back to inventory via InventoryManipulator
            } else {
                // Visitor leaving shop
                await PlayerShopRegistry.shared.removeVisitor(character.id)
            }

        case .open:
            await PlayerShopRegistry.shared.openShop(ownerID: character.id)
            // TODO: Broadcast addCharBox to map so other players see the shop

        // MARK: - Trade

        case let .setMeso(amount):
            await PlayerShopRegistry.shared.setMeso(amount, for: character.id)

        case .setItems:
            // Move item from inventory into trade window
            // TODO: Implement via InventoryManipulator + TradeSession item list
            break

        case .confirm:
            if let session = await PlayerShopRegistry.shared.confirm(characterID: character.id),
               session.isComplete {
                // Both sides confirmed — complete the trade
                await PlayerShopRegistry.shared.cancelTrade(characterID: character.id)
                // TODO: Exchange items and meso between inventories
            }

        // MARK: - Shop

        case let .addItem(inventoryType, slot, bundles, perBundle, price):
            guard let shop = await PlayerShopRegistry.shared.shop(for: character.id),
                  !shop.isOpen else { return }
            let inventory = await character.getInventory()
            let invType = InventoryType(rawValue: inventoryType) ?? .etc
            guard let item = inventory[invType][slot],
                  bundles > 0, perBundle > 0,
                  item.quantity >= UInt16(bundles) * UInt16(perBundle) else { return }
            let shopItem = PlayerShopItem(
                itemID: item.itemId,
                slot: slot,
                bundles: UInt16(bundles),
                pricePerBundle: price
            )
            await PlayerShopRegistry.shared.addItem(shopItem, to: character.id)
            // TODO: Remove item from inventory and send PLAYER_INTERACTION item update

        case let .removeItem(slot):
            guard let _ = await PlayerShopRegistry.shared.shop(for: character.id) else { return }
            if let removed = await PlayerShopRegistry.shared.removeItem(slot: Int(slot), from: character.id) {
                _ = removed
                // TODO: Return item to inventory and send PLAYER_INTERACTION item update
            }

        case let .buy(slot, quantity):
            guard let visitedShop = await PlayerShopRegistry.shared.shopVisiting(visitorID: character.id) else { return }
            if let (item, totalPrice) = await PlayerShopRegistry.shared.buyItem(
                slot: Int(slot),
                quantity: UInt16(quantity),
                from: visitedShop.ownerID
            ) {
                _ = (item, totalPrice)
                // TODO: Deduct meso from buyer, add to seller, add item to buyer inventory
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
