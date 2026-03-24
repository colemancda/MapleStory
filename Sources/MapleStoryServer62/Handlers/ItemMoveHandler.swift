//
//  ItemMoveHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct ItemMoveHandler: PacketHandler {

    public typealias Packet = MapleStory62.ItemMoveRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else {
            return
        }

        let inventory = await character.getInventory()
        let inventoryType = InventoryType(rawValue: packet.inventoryType) ?? .equip

        // Get source item
        guard let item = inventory[inventoryType][Int8(packet.sourceSlot)] else {
            return // Item doesn't exist
        }

        // Determine operation type
        let isEquipping = packet.destinationSlot < 0
        let isUnequipping = packet.sourceSlot < 0 && packet.destinationSlot >= 0

        if isEquipping && item.isEquipment {
            // Equip the item
            let manipulator = InventoryManipulator()
            try await manipulator.equip(item, for: character)

            // Update visible appearance if equipping visible gear
            // TODO: Update character.equipment dictionary

        } else if isUnequipping {
            // Unequip the item
            let manipulator = InventoryManipulator()
            try await manipulator.unequip(item, for: character)

        } else {
            // Regular move within inventory
            let manipulator = InventoryManipulator()
            try await manipulator.move(item, toSlot: Int8(packet.destinationSlot), in: inventoryType, for: character)
        }

        // Save updated inventory
        try await connection.database.insert(character)

        // Send inventory update packet
        // TODO: Send ModifyInventoryItem packet with updated slot info
    }
}
