//
//  ItemPickupHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct ItemPickupHandler: PacketHandler {

    public typealias Packet = MapleStory83.ItemPickupRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else {
            return
        }

        guard let mapItem = await MapItemRegistry.shared.drop(
            objectID: packet.objectID,
            on: character.currentMap
        ) else {
            return
        }

        if mapItem.isExpired {
            await MapItemRegistry.shared.removeDrop(objectID: packet.objectID, from: character.currentMap)
            return
        }

        guard mapItem.canPickUp(by: character.index) else {
            return
        }

        let dropPosition = PlayerPosition(x: mapItem.position.x, y: mapItem.position.y)
        let inRange = await PlayerPositionRegistry.shared.isInRange(
            characterID: character.id,
            position: dropPosition,
            range: 150
        )

        guard inRange else {
            return
        }

        if mapItem.itemID == 0 {
            character.meso = UInt32(min(Int64(character.meso) + Int64(mapItem.quantity), Int64(UInt32.max)))
            try await connection.database.insert(character)
        } else {
            let manipulator = InventoryManipulator()

            guard try await manipulator.checkSpace(
                mapItem.itemID,
                quantity: UInt16(mapItem.quantity),
                for: character
            ) else {
                return
            }

            try await manipulator.addFromDrop(
                mapItem.itemID,
                quantity: UInt16(mapItem.quantity),
                to: character
            )

            try await connection.database.insert(character)
        }

        await MapItemRegistry.shared.removeDrop(objectID: packet.objectID, from: character.currentMap)

        try await connection.broadcast(RemoveItemFromMapNotification(
            animation: 1,
            objectID: packet.objectID
        ), map: character.currentMap)
    }
}
