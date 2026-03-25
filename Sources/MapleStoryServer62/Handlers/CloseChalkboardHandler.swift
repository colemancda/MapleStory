//
//  CloseChalkboardHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles closing of chalkboard messages.
///
/// # Chalkboard System
///
/// Chalkboards are items that allow players to display text messages
/// above their character's head. These messages are visible to all
/// players in the same map and are commonly used for:
/// - Shop advertisements
/// - Party recruitment
/// - Guild recruitment
/// - General announcements
///
/// # Chalkboard Closing Flow
///
/// 1. Player has an active chalkboard message
/// 2. Player clicks to close the chalkboard
/// 3. Client sends close chalkboard request
/// 4. Server broadcasts close notification to all map players
/// 5. Chalkboard disappears from above character's head
///
/// # Chalkboard Persistence
///
/// - Chalkboards persist until manually closed
/// - Chalkboards remain when changing maps (in same channel)
/// - Chalkboards are removed when logging out
/// - Chalkboards are removed when character dies
///
/// # Broadcasting
///
/// The close notification is broadcast to:
/// - All players in the same map
/// - Only players who could see the chalkboard
/// - Players who join the map later won't see it
///
/// # Response
///
/// Sends `ChalkboardNotification.close` to all players on the map with:
/// - **characterID**: ID of character closing chalkboard
///
/// # Related Handlers
///
/// - OpenChalkboardHandler: Opens a new chalkboard message
public struct CloseChalkboardHandler: PacketHandler {

    public typealias Packet = MapleStory62.CloseChalkboardRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        _ = packet
        guard let character = try await connection.character else { return }
        try await connection.broadcast(
            ChalkboardNotification.close(characterID: character.index),
            map: character.currentMap
        )
    }
}
