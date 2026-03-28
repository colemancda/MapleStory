//
//  ItemMoveHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct ItemMoveHandler: PacketHandler {

    public typealias Packet = MapleStory83.ItemMoveRequest

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

        guard let item = inventory[inventoryType][Int8(packet.sourceSlot)] else {
            return
        }

        let isEquipping = packet.destinationSlot < 0
        let isUnequipping = packet.sourceSlot < 0 && packet.destinationSlot >= 0

        if isEquipping && item.isEquipment {
            let manipulator = InventoryManipulator()
            try await manipulator.equip(item, for: character)
        } else if isUnequipping {
            let manipulator = InventoryManipulator()
            try await manipulator.unequip(item, for: character)
        } else {
            let manipulator = InventoryManipulator()
            try await manipulator.move(item, toSlot: Int8(packet.destinationSlot), in: inventoryType, for: character)
        }

        try await connection.database.insert(character)
    }
}
