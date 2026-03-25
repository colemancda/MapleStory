//
//  CancelItemEffectHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles cancellation of item-based buff effects.
///
/// # Item Effect System
///
/// Items can provide temporary buff effects when used:
/// - **Potions**: Attack pills, speed pills, magic pills
/// - **Foods**: Items that restore HP/MP with temporary stat boosts
/// - **Scrolls**: Special items that grant temporary abilities
/// - **Event items**: Special event consumables with unique effects
///
/// # Item Effect Cancellation Flow
///
/// 1. Player uses an item with a buff effect
/// 2. Effect is applied and stored in CharacterBuffRegistry
/// 3. Player right-clicks the effect icon or effect expires
/// 4. Client sends cancel item effect request
/// 5. Server removes buff from registry
/// 6. Server sends cancellation notification to client
/// 7. Server broadcasts effect removal to all players on the map
///
/// # Item Buff Types
///
/// Common item-provided buffs:
/// - **Warrior Pills**: +10 attack
/// - **Speed Pills**: +20 speed
/// - **Magic Pills**: +10 magic attack
/// - **Dexterity Potions**: +5 DEX
/// - **Snack Bar**: +30 attack, 20% EXP boost
///
/// # Cancellation Triggers
///
/// Item effects can be cancelled by:
/// - **Right-clicking** the effect icon
/// - **Expiration**: Effect duration ends
/// - **Death**: Some effects removed on death
/// - **Map change**: Some effects don't persist
/// - **New effect**: Same effect type overwrites
///
/// # Broadcasting
///
/// Unlike skill buffs, item effect cancellations are broadcast to:
/// - The player (to remove effect from their client)
/// - All nearby players (to remove visual effects)
///
/// This is because item effects typically have visible manifestations
/// (like glowing aura) that other players should see removed.
///
/// # Response
///
/// Sends two notifications:
/// 1. `CancelBuffNotification`: Removes effect from player's client
/// 2. `CancelSkillEffectNotification`: Broadcasts removal to all map players
public struct CancelItemEffectHandler: PacketHandler {

    public typealias Packet = MapleStory62.CancelItemEffectRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        let removed = await CharacterBuffRegistry.shared.removeBuff(
            skillID: packet.skillID,
            from: character.id
        )
        guard removed else { return }

        try await connection.send(CancelBuffNotification(skillID: packet.skillID))
        try await connection.broadcast(
            CancelSkillEffectNotification(
                characterID: character.index,
                skillID: packet.skillID
            ),
            map: character.currentMap
        )
    }
}
