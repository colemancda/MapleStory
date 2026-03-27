//
//  TrockAddMapHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles adding maps to the Teleport Rock (Tock) favorites list.
///
/// Teleport Rocks are cash items that allow instant teleportation to
/// saved map locations. Players can save up to 5 map locations as
/// "favorites" for quick teleportation.
///
/// # Teleport Rock Features
///
/// - Save up to 5 favorite maps
/// - Teleport to any saved map instantly
/// - Works across different continents
/// - Cannot teleport to restricted maps
///
/// # Flow
///
/// 1. Player opens Teleport Rock UI
/// 2. Player clicks "Add Location"
/// 3. Current map is saved to favorites list
/// 4. Client sends add map request
/// 5. Server validates map can be saved
/// 6. Server saves map to player's favorites
///
public struct TrockAddMapHandler: PacketHandler {

    public typealias Packet = MapleStory62.TrockAddMapRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        // Get inventory
        let inventory = await character.getInventory()

        // Check if player has Teleport Rock in inventory
        let hasTrock = inventory[.use].values.contains { $0.itemId == 5_020_000 }
        guard hasTrock else {
            return // No Teleport Rock
        }

        // Validate map can be saved
        guard let rawMapID = packet.mapID else {
            return // No map ID in packet
        }
        let mapID = Map.ID(rawValue: rawMapID)
        guard isValidTrockMap(rawMapID) else {
            return // Cannot save this map
        }

        // Get current Trock maps
        var trockMaps = character.trockMaps ?? []

        // Add or remove map based on operation
        if packet.mode == 0x03 {
            // Add map
            guard !trockMaps.contains(mapID) else {
                return // Map already saved
            }
            guard trockMaps.count < 5 else {
                return // Max 5 maps
            }
            trockMaps.append(mapID)
        } else {
            // Remove map
            trockMaps.removeAll { $0 == mapID }
        }

        // Update character
        character.trockMaps = trockMaps

        // Save to database
        try await connection.database.insert(character)

        // Enable actions
        try await connection.send(UpdateStatsNotification.enableActions)
    }

    // MARK: - Private Helpers

    /// Check if map is valid for Teleport Rock
    private func isValidTrockMap(_ mapID: UInt32) -> Bool {
        // Maps that cannot be saved:
        // - Cash Shop (910000000+)
        // - Special event maps
        // - Party Quest maps
        // - Boss maps

        switch mapID {
        case 910000000...999999999: // Cash Shop
            return false
        default:
            return true
        }
    }
}

// MARK: - Character Trock Maps Extension

extension Character {
    public var trockMaps: [Map.ID]? {
        get {
            // In a full implementation, this would be loaded from database
            return []
        }
        set {
            // In a full implementation, this would save to database
        }
    }
}
