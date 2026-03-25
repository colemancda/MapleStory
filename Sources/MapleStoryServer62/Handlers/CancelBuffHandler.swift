//
//  CancelBuffHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles cancellation of active skill buffs.
///
/// # Buff Cancellation Flow
///
/// 1. Player right-clicks buff icon or presses skill key to cancel buff
/// 2. Client sends cancel buff request with skill ID
/// 3. Server validates player is logged in
/// 4. Server removes buff from CharacterBuffRegistry
/// 5. Server sends cancellation notification to client
/// 6. (TODO) Server recalculates character stats without buff
///
/// # Buff System
///
/// Buffs are temporary stat modifications from skills:
/// - **Attack buffs**: Increase attack power
/// - **Defense buffs**: Increase defense
/// - **Speed buffs**: Increase movement speed
/// - **Stat boosts**: Increase STR, DEX, INT, LUK
/// - **Skill buffs**: Enable special abilities
///
/// # Cancellation
///
/// Players can cancel buffs:
/// - By right-clicking the buff icon
/// - By pressing the skill key again
/// - When the buff expires naturally (timeout)
/// - When the player dies
/// - When the player changes maps (some buffs)
///
/// # TODO
///
/// - Recalculate character stats after buff removal
/// - Save character if stats were modified
/// - Handle multiple buffs that affect the same stat
/// - Broadcast buff cancellation to nearby players
public struct CancelBuffHandler: PacketHandler {

    public typealias Packet = MapleStory62.CancelBuffRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else {
            return
        }

        // Remove the buff from the registry
        let removed = await CharacterBuffRegistry.shared.removeBuff(
            skillID: packet.skillID,
            from: character.id
        )

        guard removed else {
            return // Buff wasn't active
        }

        // Send buff cancellation notification to client
        try await connection.send(CancelBuffNotification(skillID: packet.skillID))

        // TODO: Recalculate character stats without buff
        // TODO: Save character (if stats were modified)
    }
}
