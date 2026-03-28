//
//  UseCatchItemHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct UseCatchItemHandler: PacketHandler {

    public typealias Packet = MapleStory83.UseCatchItemRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        let inventory = await character.getInventory()

        guard let catchItem = inventory[.use][Int8(packet.slot)] else { return }
        guard catchItem.itemId == packet.itemID else { return }
        guard isCatchItem(packet.itemID) else { return }

        let mobRegistry = MapMobRegistry.shared
        guard let mob = await mobRegistry.instance(objectID: packet.monsterID) else { return }

        guard mob.currentHP <= mob.maxHP / 2 else {
            try await connection.send(ServerMessageNotification.popup(
                message: "You cannot catch the monster as it is too strong."
            ))
            return
        }

        if packet.itemID == 2_270_002 {
            try await connection.broadcast(CatchMonsterNotification(
                mobID: packet.monsterID,
                itemID: packet.itemID,
                success: 1
            ), map: character.currentMap)
        }

        await mobRegistry.remove(objectID: packet.monsterID)

        let manipulator = InventoryManipulator()
        _ = try await manipulator.removeById(packet.itemID, quantity: 1, from: character)

        try await connection.database.insert(character)
        try await connection.send(UpdateStatsNotification.enableActions)
    }

    private func isCatchItem(_ itemID: UInt32) -> Bool {
        return itemID >= 2_270_000 && itemID < 2_271_000
    }
}
