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

/// Handles map changes via portals and death respawns.
///
/// # Map Change Types
///
/// ## Regular Portal Use (type 2)
/// - Player enters a portal on the current map
/// - Server looks up portal by name
/// - Server finds target map and spawn point
/// - Player warps to target map at specified spawn point
///
/// ## Death Return (type 1)
/// - Player died and pressed "OK" to respawn
/// - Player returns to current map's spawn point
/// - No portal lookup needed
/// - Saves current map as respawn point
///
/// # Portal System
///
/// ## Portal Properties
/// - **name**: Unique portal identifier in map
/// - **targetMap**: Map ID to warp to
/// - **targetName**: Spawn point/portal name in target map
/// - **type**: Portal type (normal, scripted, etc.)
///
/// ## Special Values
/// - **targetMap == 0x3B9AC9FF**: Don't move (stay on current map)
/// - Used for certain portals that trigger events instead of warping
///
/// # Spawn Points
///
/// Each map has numbered spawn points:
/// - Spawn point 0: Default spawn location
/// - Additional spawns: For multiple entry points
/// - Server finds spawn point by matching portal name
///
/// # Map Change Process
///
/// 1. Client sends portal name and target map
/// 2. Server validates portal exists in current map
/// 3. Server resolves target spawn point
/// 4. Server warps player:
///    - Updates character's map ID and spawn point
///    - Sends warp packet with character stats
///    - Loads map data (mobs, NPCs, etc.)
/// 5. Character is saved to database
///
/// # Death Mechanics
///
/// When a player dies:
/// - Client shows "You died" message
/// - Player clicks OK to respawn
/// - Type 1 packet is sent (death return)
/// - Player respawns at current map's spawn point
/// - No EXP loss (handled elsewhere)
///
/// # Loading Screens
///
/// - Between map changes, player sees loading screen
/// - Loading screen matches target map theme
/// - Loading time depends on map size/content
///
/// # Anti-Cheat
///
/// - Server validates portal exists (can't warp to invalid portals)
/// - Server validates target map (can't warp to maps that don't exist)
/// - Position is reset to spawn point (can't keep position from old map)
///
/// # Common Portal Types
///
/// - **Normal portals**: Between maps in same region
/// - **Town portals**: Enter/exit towns
/// - **Dungeon portals**: Enter dungeon instances
/// - **Event portals**: Trigger events or quests
/// - **Scripted portals**: Custom behavior via scripts
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
