//
//  PetLootHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer
import MapleStoryServer62

public struct PetLootHandler: PacketHandler {

    public typealias Packet = MapleStory83.PetLootRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        let petID = PetID(packet.petID)
        guard let spawnedPet = await connection.spawnedPet(petID),
              spawnedPet.ownerID == character.id else {
            return
        }

        guard let mapItem = await connection.mapDrop(objectID: packet.objectID, on: character.currentMap) else {
            return
        }

        if mapItem.isExpired {
            await connection.removeMapDrop(objectID: packet.objectID, from: character.currentMap)
            return
        }

        let inventory = await character.getInventory()
        let isMeso = mapItem.itemID == 0

        if isMeso {
            // Meso pickup requires Meso Magnet pet equipment
            let hasMesoMagnet = inventory.equip.values.contains(where: { $0.itemId == Item.ID.mesoMagnet.rawValue })
            guard hasMesoMagnet else { return }
        } else {
            // Item pickup requires Item Pouch pet equipment
            let hasItemPouch = inventory.equip.values.contains(where: { $0.itemId == Item.ID.itemPouch.rawValue })
            guard hasItemPouch else { return }
        }

        if isMeso {
            character.meso = UInt32(min(Int64(character.meso) + Int64(mapItem.quantity), Int64(UInt32.max)))
            try await connection.database.insert(character)
        } else {
            let manipulator = InventoryManipulator()
            guard try await manipulator.checkSpace(mapItem.itemID, quantity: UInt16(mapItem.quantity), for: character) else {
                return
            }
            try await manipulator.addFromDrop(mapItem.itemID, quantity: UInt16(mapItem.quantity), to: character)
            try await connection.database.insert(character)
        }

        await connection.removeMapDrop(objectID: packet.objectID, from: character.currentMap)

        try await connection.broadcast(RemoveItemFromMapNotification(
            animation: 1,
            objectID: packet.objectID
        ), map: character.currentMap)
    }
}
