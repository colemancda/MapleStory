//
//  ItemSortHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct ItemSortHandler: PacketHandler {

    public typealias Packet = MapleStory62.ItemSortRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Get current inventory
        var inventory = await character.getInventory()

        // Sort the specified inventory
        // inventoryType: 1 = equip, 2 = use, 3 = setup, 4 = etc, 5 = cash
        switch packet.inventoryType {
        case 1: // Equip
            inventory.equip = sortItems(inventory.equip)

        case 2: // Use
            inventory.use = sortItems(inventory.use)

        case 3: // Setup
            inventory.setup = sortItems(inventory.setup)

        case 4: // Etc
            inventory.etc = sortItems(inventory.etc)

        case 5: // Cash
            inventory.cash = sortItems(inventory.cash)

        default:
            return
        }

        // Save updated inventory
        await character.setInventory(inventory)

        // TODO: Send inventory update notification to client
        // In a full implementation, we would send a ModifyInventoryItemNotification
    }

    // MARK: - Private Helpers

    /// Sort items by itemID and reassign slots sequentially
    private func sortItems(_ items: [Int8: InventoryItem]) -> [Int8: InventoryItem] {
        let sortedItems = items.values.sorted { $0.itemId < $1.itemId }
        var result = [Int8: InventoryItem]()
        var slot: Int8 = 1

        for item in sortedItems {
            var updatedItem = item
            updatedItem.slot = slot
            result[slot] = updatedItem
            slot += 1
        }

        return result
    }
}
