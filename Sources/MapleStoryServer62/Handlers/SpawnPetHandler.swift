//
//  SpawnPetHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct SpawnPetHandler: PacketHandler {

    public typealias Packet = MapleStory62.SpawnPetRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Spawn/despawn pet based on action
        // For now, we'll use a simplified approach
        // In a full implementation, we would:
        // 1. Find or create pet from the cash shop item
        // 2. Track which pet is equipped
        // 3. Send proper spawn/despawn notifications

        // TODO: Full pet spawning implementation
        return
    }
}

