//
//  ChangeMapHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct ChangeMapHandler: PacketHandler {

    public typealias Packet = MapleStory62.ChangeMapRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else {
            return
        }

        // Type 1 = death return, Type 2 = regular portal
        let isDeathWarp = packet.type == 1

        if isDeathWarp {
            // Death warp - return to spawn point of current map
            try await connection.warp(to: character.currentMap, spawn: character.spawnPoint)

        } else {
            // Regular portal use
            if packet.targetMap == 0x3B9AC9FF {
                // Special "don't move" value - stay on current map
                return
            }

            // Find portal in current map
            guard let mapData = await MapDataCache.shared.map(id: character.currentMap) else {
                return
            }
            guard let portal = mapData.portals.first(where: { $0.name == packet.portalName }) else {
                return // Portal doesn't exist
            }

            // Warp to target map at target portal
            let targetMapID = Map.ID(rawValue: portal.targetMap)
            let spawnPoint = await findSpawnPoint(named: portal.targetName, in: targetMapID)

            try await connection.warp(to: targetMapID, spawn: spawnPoint)
        }

        // Save character
        try await connection.database.insert(character)
    }

    /// Find spawn point by portal name in target map.
    private func findSpawnPoint(
        named portalName: String,
        in mapID: Map.ID
    ) async -> UInt8 {
        // Try to find portal by name in target map
        guard let targetMapData = await MapDataCache.shared.map(id: mapID) else {
            return 0
        }

        // Return the index of the portal in the portals array
        if let index = targetMapData.portals.firstIndex(where: { $0.name == portalName }) {
            return UInt8(index)
        }

        // Default to spawn point 0
        return 0
    }
}
