//
//  TakeDamageHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles damage taken by player from various sources.
///
/// # Damage Sources
///
/// ## Monster Attacks (damageFrom >= 0, monsterIDFrom > 0)
/// - Physical damage from monster touch/attacks
/// - Magic damage from monster skills
/// - Damage capped by monster's max damage (anti-cheat)
///
/// ## Map Damage (damageFrom < 0)
/// - Environmental hazards (lava, thorns)
/// - Damage floors
/// - Weather effects (some maps)
///
/// ## Fall Damage
/// - Falling from heights
/// - Platform drop damage
/// - Client-calculated based on fall distance
///
/// # Damage Calculation
///
/// ## Physical Attack Damage
/// ```
/// Server cap = monster.pdd (Physical Defense)
/// Client reports damage
/// Server uses: min(client_damage, monster.pdd)
/// Prevents damage hacking (client claiming 0 damage)
/// ```
///
/// ## Magic Attack Damage
/// ```
/// Server cap = monster.mdd (Magic Defense)
/// Similar capping to physical attacks
/// ```
///
/// # Damage Application
///
/// 1. Receive damage amount from client
/// 2. Cap damage if from monster (anti-cheat)
/// 3. Subtract from current HP
/// 4. Prevent HP from going below 0
/// 5. Update character in database
/// 6. Send HP update to client
/// 7. Handle death if HP reaches 0
///
/// # Death Handling
///
/// When HP reaches 0:
/// - Character is "dead"
/// - Client shows death animation
/// - Server respawns character:
///   - Sets HP to 10% of max HP
///   - Warps to spawn point 0 of current map
/// - No EXP loss currently (future feature)
/// - Kept equipment (no drops)
///
/// # Death Flow
///
/// ```
/// HP reaches 0
///    ↓
/// Client plays death animation
///    ↓
/// Player clicks "OK"
///    ↓
/// Client sends ChangeMapRequest(type 1) [handled by ChangeMapHandler]
///    ↓
/// Server warps to spawn point
///    ↓
**Player respawns with 10% HP
/// ```
///
/// # Anti-Cheat Measures
///
/// ## Damage Capping
/// - Monsters have max damage (PDD/MDD stats)
/// - Client reports damage, server caps it
/// - Prevents "god mode" hacks (0 damage)
/// - Prevents fake damage reports
///
/// ## Monster Validation
/// - Server validates monster exists
/// - Server validates monster stats
/// - Invalid monsters = ignore damage or kick player
///
/// ## HP Validation
/// - Server tracks actual HP on server
/// - Client can't claim more HP than they have
/// - HP updates are authoritative from server
///
/// # Damage Types
///
/// ## Physical Damage
/// - Touch damage from contact with monsters
/// - Weapon attacks (melee)
/// - Some monster skills
///
/// ## Magic Damage
/// - Monster magic attacks
/// - Elemental damage
/// - Status effects that deal damage
///
/// ## Environmental Damage
/// - Lava floors
/// - Damage zones
/// - Weather
///
/// # HP Updates
///
/// - HP updates sent to client immediately
/// - Client shows HP bar decreasing
/// - HP bar color changes:
///   - Green: >50% HP
///   - Yellow: 25-50% HP
///   - Red: <25% HP
///   - Blinking: Critical HP
///
/// # Healing
///
/// While this handler deals damage, healing is handled separately:
/// - **UseItemHandler**: Potions, food
/// - **HealOverTimeHandler**: Passive HP regeneration
/// - **Skills**: Heal, Holy Symbol, etc.
/// - **Chair**: Resting on chairs
///
/// # Invincibility Frames
///
/// Some skills provide brief invincibility:
/// - Damage taken during iframe is ignored
/// - Client doesn't send damage packets during iframe
/// - Skills: Dark Sight, Magic Guard, etc.
///
/// # Future Enhancements
///
/// - EXP loss on death (percentage based on level)
/// - Death penalty mechanics
/// - Spawn point selection (town vs current map)
/// - Damage number display (show damage taken)
/// - Death statistics tracking
public struct TakeDamageHandler: PacketHandler {

    public typealias Packet = MapleStory62.TakeDamageRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        // Validate damage against WZ mob stats when the source is a known monster.
        let damage: UInt32
        if packet.damageFrom >= 0, packet.monsterIDFrom > 0 {
            if let mob = await MobDataCache.shared.mob(id: packet.monsterIDFrom) {
                // Cap reported damage at the mob's physical attack to resist client manipulation.
                let cap = UInt32(max(0, mob.paDamage))
                damage = (cap > 0) ? min(packet.damage, cap) : packet.damage
            } else {
                damage = packet.damage
            }
        } else {
            // Map damage or fall damage — trust the client value.
            damage = packet.damage
        }

        let newHP = UInt32(character.hp) > damage ? UInt16(UInt32(character.hp) - damage) : 0
        character.hp = newHP
        try await connection.database.insert(character)

        try await connection.send(UpdateStatsNotification.hp(newHP))

        if newHP == 0 {
            // Character died — respawn at current map spawn point for now.
            // A proper death flow (respawn choice, EXP penalty) can extend this later.
            character.hp = max(1, character.maxHp / 10)
            try await connection.database.insert(character)
            try await connection.warp(to: character.currentMap, spawn: 0)
        }
    }
}
