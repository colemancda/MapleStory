//
//  ChangeMapSpecialHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles special map changes via scripted portals.
///
/// # Special Map Change System
///
/// This handler is similar to ChangeMapHandler but handles special
/// portal transitions that use different packet format. These are typically
/// triggered by scripted portals or special map transition events.
///
/// # Special Portal Use Flow
///
/// 1. Player interacts with a special/inner portal
/// 2. Client sends special map change request
/// 3. Server validates portal exists in current map (using startwp)
/// 4. Server resolves target map from portal data
/// 5. Server finds spawn point in target map (by portal name)
/// 6. Server warps player to target map
/// 7. Character is saved to database
///
/// # Difference from Regular ChangeMapHandler
///
/// | Feature | ChangeMapHandler | ChangeMapSpecialHandler |
/// |----------|------------------|-------------------------|
/// | Packet format | Regular change map | Special change map |
/// | Portal lookup | Uses portalName field | Uses startwp field |
/// | Death handling | Supports type 1 (death) | No death handling |
/// | Special values | Checks for 0x3B9AC9FF | No special value check |
///
/// # Use Cases
///
/// This handler is used for:
/// - **Inner portals**: Portals within maps (e.g., PQ rooms)
/// - **Scripted portals**: Portals with custom behavior
/// - **Event portals**: Special event-related transitions
/// - **Instance portals**: Entering/leaving instances
///
/// # Portal Resolution
///
/// 1. Looks up portal by `startwp` name in current map
/// 2. Gets target map ID from portal data
/// 3. Gets target portal name from portal data
/// 4. Finds spawn point index in target map by portal name
/// 5. Warps player to target map at spawn point
///
/// # Spawn Point Fallback
///
/// If target portal name is not found in target map:
/// - Falls back to spawn point 0 (default spawn)
/// - This prevents crashes if portal data is inconsistent
///
/// # Response
///
/// No explicit response. The warp operation sends:
/// - WarpToMapNotification with character stats
/// - Map data (mobs, NPCs, portals)
/// - Player appears at spawn point on new map
public struct ChangeMapSpecialHandler: PacketHandler {

    public typealias Packet = MapleStory62.ChangeMapSpecialRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else {
            return
        }

        // Find portal in current map using startwp
        guard let mapData = await MapDataCache.shared.map(id: character.currentMap) else {
            return
        }
        guard let portal = mapData.portals.first(where: { $0.name == packet.startwp }) else {
            return // Portal doesn't exist
        }

        // Warp to target map at target portal
        let targetMapID = Map.ID(rawValue: portal.targetMap)
        let spawnPoint = await findSpawnPoint(named: portal.targetName, in: targetMapID)

        try await connection.warp(to: targetMapID, spawn: spawnPoint)

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
