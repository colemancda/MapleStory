//
//  CancelChairHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles cancellation of chair usage.
///
/// # Chair System
///
/// Chairs are items that players can sit on to restore HP/MP or for
/// decorative purposes. When a player uses a chair, they sit down and
/// gain passive benefits.
///
/// # Chair Cancellation Flow
///
/// 1. Player is sitting on a chair
/// 2. Player presses jump key, attack key, or moves
/// 3. Client sends cancel chair request
/// 4. Server sends cancel chair notification
/// 5. Client removes chair effect and stands up player
///
/// # Chair Effects
///
/// Common chair benefits:
/// - **HP/MP Recovery**: Passive regeneration while sitting
/// - **Stat boosts**: Some chairs provide temporary stat increases
/// - **Cosmetic**: Purely decorative chairs for show
///
/// # Chair Cancellation Triggers
///
/// Players automatically cancel chair usage when:
/// - Pressing jump key
/// - Pressing attack key
/// - Using a skill
/// - Picking up an item
/// - Moving to another position
/// - Changing maps
///
/// # Response
///
/// Sends `CancelChairNotification` to:
/// - Remove chair effect from client
/// - Restore normal character state
/// - Allow character to move/attack again
///
/// # Broadcasting
///
/// Chair state changes are typically visible to nearby players,
/// so other players see the character stand up.
public struct CancelChairHandler: PacketHandler {

    public typealias Packet = MapleStory62.CancelChairRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Cancel chair - send cancel chair packet to client
        // This removes the chair effect on the client side
        try await connection.send(CancelChairNotification(
            characterID: character.index
        ))
    }
}
