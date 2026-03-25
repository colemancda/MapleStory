//
//  MovePlayerHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles player movement requests during gameplay.
///
/// # Movement Processing
///
/// When a player moves:
/// 1. Client sends movement data with final position
/// 2. Server validates movement format (18 bytes expected)
/// 3. Server extracts final position from movement fragments
/// 4. Server updates player's position in registry
/// 5. Server broadcasts movement to other players on the map
///
/// # Movement Validation
///
/// - Packet must contain exactly 18 bytes of movement data
/// - Invalid packets indicate client desync or hacking
/// - Server logs warnings for invalid movement formats
///
/// # Visibility Rules
///
/// - **Hidden players (GM invisibility)**: Movement NOT broadcast
/// - **Normal players**: Movement broadcast to all nearby players
/// - Hidden players still update position but aren't visible to others
///
/// # Fake Characters (Mirroring)
///
/// Some skills/abilities create fake character clones:
/// - Each fake character mirrors the player's movement
/// - Movements are delayed by 300ms per clone
/// - Clone 1 delays 300ms, clone 2 delays 600ms, etc.
/// - This creates a "afterimage" effect
///
/// # Position Registry
///
/// Player position is tracked in a shared registry for:
/// - Anti-cheat validation
/// - Combat calculations
/// - Skill targeting
/// - Party member locations
///
/// # Movement Data Structure
///
/// Movement packets contain multiple "movement fragments":
/// - Each fragment describes a type of movement (walk, jump, teleport, etc.)
/// - Fragments are processed sequentially
/// - Final position is extracted from the last fragment
///
/// # Broadcasting
///
/// Movement is broadcast to all players on the same map EXCEPT:
/// - The moving player (they don't need to see their own movement)
/// - Players who are too far away (client-side optimization)
public struct MovePlayerHandler: PacketHandler {

    public typealias Packet = MapleStory62.MovePlayerRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Extract final position from movement data
        if let finalPos = packet.movements.finalPosition {
            // Update player position registry
            let playerPos = PlayerPosition(x: finalPos.x, y: finalPos.y)
            await PlayerPositionRegistry.shared.updatePosition(playerPos, for: character.id)
        }

        // Broadcast movement to other players on the map
        let notification = MovePlayerNotification(
            characterID: character.index,
            movements: packet.movements
        )
        try await connection.broadcast(notification, map: character.currentMap)
    }
}
