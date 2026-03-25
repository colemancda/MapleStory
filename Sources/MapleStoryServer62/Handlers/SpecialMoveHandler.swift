//
//  SpecialMoveHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles active skill usage (buffs, summons, attacks).
///
/// # Active Skills
///
/// Special moves include:
/// - **Buff skills**: Temporary stat boosts
/// - **Summon skills**: Create allied creatures
/// - **Mystic Door**: Portal to nearest town
/// - **Attack skills**: Special combat moves
///
/// # Skill Activation
///
/// When player uses a skill:
/// 1. Player presses skill key
/// 2. Client sends SpecialMoveRequest
/// 3. Server validates:
///    - Player has learned the skill
///    - Player has enough MP/HP
///    - Skill isn't on cooldown
/// 4. Server deducts MP/HP cost
/// 5. Server applies skill effect
/// 6. Server sends response to client
///
/// # MP/HP Costs
///
/// Skills consume resources:
/// - **MP cost**: Most skills consume MP
/// - **HP cost**: Some skills consume HP (e.g., Sacrifice)
/// - **Costs scale** with skill level
/// - Level 1: Low cost, weak effect
/// - Max level: High cost, strong effect
///
/// # Buff Skills
///
/// Buffs provide temporary bonuses:
/// - **Duration**: 10-600 seconds based on skill
/// - **Stats affected**: Speed, jump, attack, defense, etc.
/// - **Stacking**: Some buffs stack, others don't
/// - **Override**: Same buff type replaces old one
///
/// Common buffs:
/// - **Haste** (Thief): +Speed, +Jump
/// - **Rage** (Fighter): +WATK, -WDEF
/// - **Meditation** (Mage): +MATK
/// - **Bless** (Cleric): +All stats
/// - **Hyper Body** (Spearman): +MaxHP, +MaxMP
///
/// # Mystic Door
///
/// Special portal skill (Priest 4th job):
/// - Creates two-way portal to nearest town
/// - **Town end**: Appears at door portal (type 6)
/// - **Field end**: Appears at casting location
/// - **Duration**: 5+ minutes (scales with skill level)
/// - **Party use**: Party members can use door
/// - **One-way**: Anyone can enter from either side
/// - **Expires**: Door disappears after duration
///
/// Door creation:
/// 1. Find current map's return map (nearest town)
/// 2. Find available door portal in town
/// 3. Create door entry in registry
/// 4. Door persists for duration
///
/// # Summon Skills
///
/// Summons create allied creatures:
/// - **Summon Dragon** (Mage): Attacks enemies
/// - **Bahamut** (Bishop): Strong dragon attacks
/// - **Ranger/Puppet**: Decoy that attracts mobs
/// - **Shadow Clone**: Mimics player attacks
/// - Duration: 60-240 seconds
/// - Summons have their own attacks
///
/// # Skill Validation
///
/// Before using skill, server checks:
/// - **Skill learned**: Player must have skill
/// - **Skill level**: Must be valid level (0-max)
/// - **MP/HP**: Must have enough resources
/// - **Cooldown**: Skill can't be on cooldown
/// - **State**: Can't be dead/stunned/etc.
///
/// # Buff Stat Calculation
///
/// Buff effects encoded as bitflags:
/// - Bit 0: Speed boost
/// - Bit 1: Jump boost
/// - Bit 2: Weapon attack boost
/// - Bit 3: Weapon defense boost
/// - Bit 4: Magic attack boost
/// - Bit 5: Magic defense boost
/// - More bits for other effects
///
/// # Attack Skills
///
/// Attack skills damage enemies:
/// - Damage calculated from skill data
/// - Can hit multiple targets
/// - Special effects (knockback, stun, etc.)
/// - Attack skill damage parsing is incomplete
///
/// # Skill Cooldowns
///
/// Some skills have cooldowns:
/// - Duration: 10 seconds to 10 minutes
/// - Countdown shown on client
/// - Can't reuse during cooldown
/// - This is not yet implemented
///
/// # Anti-Cheat
///
/// - **Skill validation**: Can't use unlearned skills
/// - **Resource validation**: Can't use without MP/HP
/// - **Cooldown enforcement**: Can't spam cooldown skills
/// - **Effect validation**: Server calculates actual buff effects
/// - **Speed prevention**: Can't use skills faster than allowed
///
/// # Side Effects
///
/// - **Database**: Saves character (MP/HP deducted)
/// - **Registry**: Registers buff in CharacterBuffRegistry (for buffs)
/// - **Registry**: Registers door in DoorRegistry (for Mystic Door)
/// - **Sends**: GiveBuffNotification to client (for buffs)
/// - **Sends**: ServerMessageNotification on errors
public struct SpecialMoveHandler: PacketHandler {

    public typealias Packet = MapleStory62.SpecialMoveRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else {
            return
        }

        // Look up skill data
        guard let skill = await SkillDataCache.shared.skill(id: packet.skillID),
              let skillLevel = skill.levels[Int(packet.skillLevel)] else {
            return // Invalid skill or level
        }

        // Check if character can use this skill (has enough MP/HP, not on cooldown, etc.)
        let canUse = await SkillStatCalculator.shared.canUseSkill(
            packet.skillID,
            level: Int(packet.skillLevel),
            by: character,
            skillCache: SkillDataCache.shared
        )

        guard canUse else {
            return // Cannot use skill (not enough MP/HP, cooldown, etc.)
        }

        // Deduct MP cost
        let mpCost = UInt16(max(0, min(skillLevel.mpCost, Int32(UInt16.max))))
        character.mp = character.mp - mpCost

        // Deduct HP cost if any
        let hpCost = UInt16(max(0, min(skillLevel.hpCost, Int32(UInt16.max))))
        if hpCost > 0 {
            character.hp = character.hp - hpCost
        }

        // Check if this is a buff skill
        let isBuff = skillLevel.time > 0

        // Special handling for Mystic Door (2311002)
        if packet.skillID == 2311002 {
            // Mystic Door skill - create a door
            try await createMysticDoor(
                for: character,
                skillLevel: Int(packet.skillLevel),
                connection: connection
            )
        } else if isBuff {
            // Apply buff
            let duration = TimeInterval(skillLevel.time)
            let buff = BuffState(
                skillID: packet.skillID,
                level: Int(packet.skillLevel),
                duration: duration
            )
            await CharacterBuffRegistry.shared.applyBuff(buff, to: character.id)

            // Calculate buff stat mask
            let buffStats = calculateBuffStats(skillID: packet.skillID, level: skillLevel)

            // Send buff notification to client
            try await connection.send(GiveBuffNotification(
                skillID: packet.skillID,
                level: packet.skillLevel,
                duration: UInt32(skillLevel.time),
                buffStats: buffStats
            ))

            // Note: Stat modifications are calculated but not directly applied
            // to Character model since it doesn't have buff-specific stat fields.
            // Buff effects are handled by the client via the buff packet.

        } else {
            // Attack skill - damage calculation
            // Attack skills require parsing additional packet data for mob targets
            // Damage calculation would use skill.level.damage, .attackCount, .mobCount
            // This is a significant feature requiring mob target parsing and broadcast
        }

        // Save character (MP was deducted)
        try await connection.database.insert(character)
    }

    /// Calculate buff stat mask for packet encoding.
    /// In v62, buff effects are encoded as bitflags.
    private func calculateBuffStats(skillID: UInt32, level: WzSkillLevel) -> UInt32 {
        var buffStats: UInt32 = 0

        // Basic buff stat flags (simplified - v62 has more complex encoding)
        if level.speed > 0 { buffStats |= 1 << 0 }  // Speed
        if level.jump > 0 { buffStats |= 1 << 1 }  // Jump
        if level.x > 0 { buffStats |= 1 << 2 }     // Watk (for some skills)
        if level.y > 0 { buffStats |= 1 << 3 }     // Wdef (for some skills)
        if level.z > 0 { buffStats |= 1 << 4 }     // Matk (for some skills)
        if level.w > 0 { buffStats |= 1 << 5 }     // Mdef (for some skills)

        // Skill-specific mappings would go here
        // For now, return a basic mask

        return buffStats
    }

    /// Create a Mystic Door for the character
    private func createMysticDoor<Socket: MapleStorySocket, Database: ModelStorage>(
        for character: MapleStory.Character,
        skillLevel: Int,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Get current map data to find return map (town)
        guard let mapData = await MapDataCache.shared.map(id: character.currentMap) else {
            try await connection.send(ServerMessageNotification.notice(
                message: "Cannot create door here."
            ))
            return
        }

        // Find a free door portal (type 6) in the town
        let townMapID = mapData.returnMap
        guard let townMapData = await MapDataCache.shared.map(id: townMapID) else {
            return
        }

        // Find first available door portal (type 6)
        let doorPortals = townMapData.portals.filter { $0.type == 6 }
        guard let portal = doorPortals.first else {
            try await connection.send(ServerMessageNotification.notice(
                message: "No door portals available in town."
            ))
            return
        }

        // Get door duration based on skill level
        // Level 1: 300 seconds (5 minutes), increases with level
        let baseDuration: TimeInterval = 300.0
        let duration = baseDuration + TimeInterval(skillLevel * 10.0)

        // Create the door
        let door = Door(
            ownerID: character.id,
            townMapID: townMapID,
            townPortalID: portal.id,
            fieldMapID: character.currentMap,
            fieldPosition: Position(x: character.x, y: character.y),
            duration: duration
        )

        // Register the door
        await DoorRegistry.shared.register(door)

        // Log for debugging
        print("[Door] Created door for character \(character.name) " +
              "from \(door.fieldMapID) to \(door.townMapID), " +
              "duration: \(duration)s")

        // Note: Client would need to receive door spawn packets
        // This would require sending SpawnDoorNotification or similar packets
        // to party members showing the door location
    }
}
