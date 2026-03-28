//
//  UseReturnScrollHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct UseReturnScrollHandler: PacketHandler {

    public typealias Packet = MapleStory83.UseReturnScrollRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        let inventory = await character.getInventory()

        guard let scrollItem = inventory[.use][Int8(packet.slot)] else { return }
        guard scrollItem.itemId == packet.itemID else { return }
        guard isReturnScroll(packet.itemID) else { return }

        let returnMap = getReturnTown(for: character.currentMap)

        let manipulator = InventoryManipulator()
        _ = try await manipulator.removeById(packet.itemID, quantity: 1, from: character)

        try await connection.database.insert(character)
        try await connection.warp(to: returnMap, spawn: 0)
        try await connection.send(UpdateStatsNotification.enableActions)
    }

    private func isReturnScroll(_ itemID: UInt32) -> Bool {
        return itemID >= 2_030_000 && itemID < 2_040_000
    }

    private func getReturnTown(for mapID: Map.ID) -> Map.ID {
        switch mapID.rawValue {
        case 100000000...200000000:
            return Map.ID(rawValue: 100000000)
        case 101000000, 101000001, 101000002, 101000003, 101000004:
            return Map.ID(rawValue: 101000000)
        case 102000000, 102000001, 102000003, 102000005:
            return Map.ID(rawValue: 102000000)
        case 103000000, 103000001, 103000004, 103000005:
            return Map.ID(rawValue: 103000000)
        case 104000000, 104000001:
            return Map.ID(rawValue: 104000000)
        default:
            return Map.ID(rawValue: 100000000)
        }
    }
}
