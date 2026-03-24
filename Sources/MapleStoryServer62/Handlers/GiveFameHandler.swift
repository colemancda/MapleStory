//
//  GiveFameHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct GiveFameHandler: PacketHandler {

    public typealias Packet = MapleStory62.GiveFameRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let fromCharacter = try await connection.character else { return }

        // Find target character on same map
        let targetCharacters = await connection.characters(on: fromCharacter.currentMap)
        guard let toCharacter = targetCharacters.first(where: { $0.index == packet.characterID }) else {
            return // Target not found on same map
        }

        // Check level requirement (must be level 15+)
        guard toCharacter.level >= 15 else {
            return // Target too low level
        }

        // Check if can give fame (once per day)
        let canGive = await FameRegistry.shared.canGiveFame(
            from: fromCharacter.id,
            to: toCharacter.id
        )
        guard canGive else {
            return // Already gave fame today
        }

        // Update fame
        let fameChange = packet.mode == 1 ? 1 : -1
        let newFame = max(0, min(Int32(toCharacter.fame) + Int32(fameChange), 30000))

        // Record fame transaction
        await FameRegistry.shared.recordFame(
            from: fromCharacter.id,
            to: toCharacter.id
        )

        // Update target character (if it's someone else)
        if toCharacter.id != fromCharacter.id {
            var updatedCharacter = toCharacter
            updatedCharacter.fame = UInt16(newFame)
            try await connection.database.insert(updatedCharacter)
        }

        // Send fame response notification
        try await connection.send(FameResponseNotification(
            success: true,
            newFame: UInt16(newFame)
        ))
    }
}

// MARK: - Fame Registry

/// Tracks fame transactions to prevent abuse (once per day per person)
public actor FameRegistry {

    public static let shared = FameRegistry()

    /// Key: (fromCharacterID, toCharacterID, datestamp) -> Bool
    private var fameRecords: [String: Date] = [:]

    private init() {}

    /// Check if character can give fame to target (once per day)
    public func canGiveFame(from: Character.ID, to: Character.ID) -> Bool {
        let key = "\(from.uuidString)-\(to.uuidString)"
        guard let lastDate = fameRecords[key] else {
            return true // Never given fame before
        }

        // Check if last fame was more than 24 hours ago
        let hoursSince = Date().timeIntervalSince(lastDate) / 3600
        return hoursSince >= 24
    }

    /// Record a fame transaction
    public func recordFame(from: Character.ID, to: Character.ID) {
        let key = "\(from.uuidString)-\(to.uuidString)"
        fameRecords[key] = Date()
    }

    /// Clear old records (call periodically to save memory)
    public func cleanupOldRecords() {
        let cutoffDate = Date().addingTimeInterval(-24 * 3600) // 24 hours ago
        fameRecords = fameRecords.filter { $0.value > cutoffDate }
    }
}
