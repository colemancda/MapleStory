//
//  UseMountFoodHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles mount food usage (feeding player's mount/pet).
///
/// Mounts are rideable creatures that can be tamed and fed with mount food.
/// Feeding a mount increases its closeness and loyalty.
/// and prevents the mount from running away.
///
/// # Mount Types
///
/// - **Hog**: Common mount, - **Silver Mane**: Fast mount
/// - **Red Draco**: Flying mount
/// - **Black Sack**: Two-person mount
///
/// # Mount Care
///
/// - Mounts have to be fed regularly to maintain closeness
/// - Low closeness may mount may run away
/// - Mount level affects speed and abilities
///
public struct UseMountFoodHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseMountFoodRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        // Get inventory
        let inventory = await character.getInventory()

        // Get mount food from USE inventory
        guard let foodItem = inventory[.use][Int8(packet.slot)] else {
            return // Item doesn't exist
        }

        // Validate it's the correct item
        guard foodItem.itemId == packet.itemID else {
            return // Item mismatch
        }

        // Validate it's mount food (item ID 2260xxx)
        guard isMountFood(packet.itemID) else {
            return // Not mount food
        }

        // Check if player has a mount
        guard var mount = character.mount else {
            return // Player has no mount
        }

        // Increase mount closeness (simplified - actual value depends on food type)
        let closenessGain = getClosenessGain(for: packet.itemID)
        mount.closeness = min(mount.closeness + closenessGain, 30_000) // Max closeness

        // Update character mount
        character.mount = mount

        // Consume the food
        let manipulator = InventoryManipulator()
        _ = try await manipulator.removeById(packet.itemID, quantity: 1, from: character)

        // Save character
        try await connection.database.insert(character)

        // Enable actions
        try await connection.send(UpdateStatsNotification.enableActions)
    }

    // MARK: - Private Helpers

    private func isMountFood(_ itemID: UInt32) -> Bool {
        // Mount food is in the 2260xxx range
        return itemID >= 2_260_000 && itemID < 2_261_000
    }

    private func getClosenessGain(for itemID: UInt32) -> Int {
        // Simplified closeness gain calculation
        // In a full implementation, this would be based on the specific food item
        switch itemID {
        case 2_260_000: // Regular mount food
            return 5
        case 2_260_001: // Premium mount food
            return 10
        default:
            return 5
        }
    }
}

// MARK: - Character Mount Extension

extension Character {
    public var mount: MountData? {
        get {
            // Simplified - in a full implementation, this would be stored in the database
            return MountData(level: 1, exp: 0, closeness: 0, fatigue: 0)
        }
        set {
            // In a full implementation, this would save to the database
        }
    }
}

/// Mount data structure
public struct MountData: Sendable {
    public let level: Int
    public let exp: Int
    public let closeness: Int
    public let fatigue: Int
}
