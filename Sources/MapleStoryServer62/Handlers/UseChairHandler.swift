//
//  UseChairHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles portable chair item usage (sit on chairs).
///
/// Portable chairs are cash items that allow characters to sit anywhere
/// and recover HP over time. Sitting on a chair also displays
/// a chair icon above the character's head.
///
/// # Chair Types
///
/// - **Regular chairs**: Basic sitting recovery
/// - **Relaxation chairs**: Enhanced HP recovery
/// - **Mini chairs**: Smaller, faster recovery
///
/// # Flow
///
/// 1. Player double-clicks chair item in cash inventory
/// 2. Character sits on the chair
/// 3. Client sends use chair request
/// 4. Server validates chair item
/// 5. Server updates character state (sitting)
/// 6. Server broadcasts chair state to other players
///
/// # HP Recovery
///
/// While sitting on a chair, the character recovers HP at a
/// faster rate than standing. The recovery rate depends on:
/// - Chair type
/// - Character's max HP
/// - Time spent sitting
public struct UseChairHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseChairRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Validate chair item ID (starts with 301)
        guard packet.itemID / 1000 == 301 else {
            return // Not a chair item
        }

        // Send chair notification to spawn the chair on client
        try await connection.send(ShowChairNotification(
            characterID: character.index,
            itemID: packet.itemID
        ))

        // TODO: Start HP/MP regeneration timer while sitting
        // In a full implementation, we would:
        // 1. Store which chair the character is using
        // 2. Start a timer to periodically restore HP/MP
        // 3. Stop regeneration when character stands up
    }
}
