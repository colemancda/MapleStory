//
//  CancelDebuffHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles cancellation of active debuffs.
///
/// # Debuff System
///
/// Debuffs are temporary negative status effects that reduce character
/// capabilities. They are typically caused by monster attacks, skills, or
/// environmental hazards.
///
/// # Common Debuffs
///
/// - **Poison**: Continuous damage over time
/// - **Seal**: Cannot use skills
/// - **Stun**: Cannot move or act
/// - **Slow**: Reduced movement speed
/// - **Weaken**: Reduced defense
/// - **Darkness**: Reduced accuracy
/// - **Curse**: Reduced EXP gain
/// - **Freeze**: Frozen in place
///
/// # Debuff Cancellation Flow
///
/// 1. Character is affected by one or more debuffs
/// 2. Player uses all-cure potion or debuff expires
/// 3. Client sends cancel debuff request
/// 4. Server cleans up expired buffs from registry
/// 5. (TODO) Server debuffs state tracking and notifications
///
/// # Cancellation Methods
///
/// Debuffs can be removed by:
/// - **All-cure potion**: Removes all debuffs
/// - **Specific cure potions**: Remove specific debuff types
/// - **Bishop skills**: Dispel removes negative effects
/// - **Natural expiration**: Debuff wears off over time
/// - **Death**: Some debuffs are removed on death
///
/// # Implementation Status
///
/// ⚠️ **PARTIALLY IMPLEMENTED**
///
/// Debuff state is not yet tracked separately. The handler currently only
/// cleans up expired buffs from the CharacterBuffRegistry. Full debuff
/// tracking, notifications, and visual effects need to be implemented.
///
/// # TODO
///
/// - Track active debuffs separately from buffs
/// - Send debuff cancellation notifications to client
/// - Update character stats after debuff removal
/// - Handle visual effects for debuff states
/// - Broadcast debuff removal to nearby players
public struct CancelDebuffHandler: PacketHandler {

    public typealias Packet = MapleStory62.CancelDebuffRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        _ = packet
        guard let character = try await connection.character else { return }

        // Debuff state is not tracked separately yet; at minimum keep buff registry clean.
        await CharacterBuffRegistry.shared.cleanupExpired(for: character.id)
    }
}
