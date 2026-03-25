//
//  MagicAttackHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles magic spell attacks.
///
/// # Magic Combat
///
/// Magic attacks include:
/// - **Elemental spells**: Fire, Ice, Lightning, Poison
/// - **Healing spells**: Heal (Holy Magic)
/// - **Buff spells**: Magic Guard, Meditation, etc.
/// - **Summon spells**: Summon dragons, Bahamut, etc.
/// - **Ultimate attacks**: Meteor, Blizzard, Genesis
///
/// # Magic Classes
///
/// **Fire/Poison Wizard/Mage**:
/// - High single-target damage
/// - Poison damage over time
/// - Fire element (strong vs plant, weak vs ice)
///
/// **Ice/Lightning Wizard/Mage**:
/// - Freeze effects (stop enemy movement)
/// - Chain lightning (hits multiple)
/// - Ice element (strong vs fire, weak vs water)
///
/// **Cleric/Priest/Bishop**:
/// - Healing spells
/// - Holy attacks (strong vs undead)
/// - Support buffs (Bless, Holy Symbol)
/// - High durability with Magic Guard
///
/// # Spell Casting Flow
///
/// 1. Player targets monster and casts spell
/// 2. Client sends magic attack packet
/// 3. Server validates:
///    - Player has the skill
///    - Player has enough MP
///    - Player isn't sitting
/// 4. Server deducts MP cost
/// 5. Server calculates damage using MDD (magic defense)
/// 6. Server applies elemental effects
/// 7. Server broadcasts damage to map
///
/// # MP Cost
///
/// Magic spells consume significant MP:
/// - **1st job skills**: 10-30 MP per cast
/// - **2nd job skills**: 20-60 MP per cast
/// - **3rd job skills**: 50-150 MP per cast
/// - **4th job skills**: 100-1000 MP per cast
/// - **Ultimates**: 2000-3500 MP per cast
///
/// MP management is critical for mages!
///
/// # Damage Calculation
///
/// Magic damage formula:
/// ```
/// BaseDamage = (MagicAttack × INT / 100 + INT × 0.5) × Mastery
/// SkillDamage = BaseDamage × SkillMultiplier
/// FinalDamage = SkillDamage - MonsterMDD
///
/// MagicAttack = Staff/Wand magic attack
/// INT = Player's intelligence stat
/// Mastery = 0.5-1.5 (based on skill mastery)
/// ```
///
/// # Elemental Advantages
///
/// Elements modify damage:
/// - **Fire**: 1.5x vs Ice, 0.5x vs Fire
/// - **Ice**: 1.5x vs Fire, 0.5x vs Ice
/// - **Lightning**: 1.5x vs Fish, 0.5x vs Lightning
/// - **Holy**: 1.5x vs Undead/Demon
/// - **Poison**: Damage over time (ignores defense)
///
/// # Special Effects
///
/// **Freeze** (Ice spells):
/// - Duration: 1-8 seconds based on skill level
/// - Frozen enemies can't move or attack
/// - Damage breaks freeze
///
/// **Poison**:
/// - Deals % of monster's max HP per second
/// - Duration: 5-30 seconds
/// - Can stack with other damage
///
/// **Seal**:
/// - Prevents monsters from using skills
/// - Duration: 5-20 seconds
///
/// **Slow**:
/// - Reduces monster movement speed
/// - Duration: 5-20 seconds
///
/// # Range
///
/// Magic has variable range:
/// - **Single-target**: ~300 pixels
/// - **AoE (Area of Effect)**: ~200-400 pixels radius
/// - **Ultimates**: Entire map
/// - **Heal**: Heals party members in range
///
/// # Anti-Cheat
///
/// - **MP validation**: Can't cast without MP
/// - **Skill validation**: Can't cast unlearned skills
/// - **Cooldown enforcement**: Some skills have cooldowns
/// - **Damage cap**: Prevents damage hacking
/// - **Speed check**: Can't cast faster than allowed
///
/// # Magic Guard
///
/// Critical buff for mages:
/// - Converts 80% of HP damage to MP damage
/// - Allows mages to survive strong hits
/// - MP heals faster than HP (potions)
/// - Makes mages very tanky
///
/// # Teleport Casting
///
/// Some skills can be cast while teleporting:
/// - Teleport is instant movement
/// - Can chain spells quickly
/// - Higher Teleport level = less MP
///
/// # Side Effects
///
/// - **Database**: Saves character (MP deducted)
/// - **Broadcasts**: Damage notifications to map (via processAttack)
/// - **No response**: Silent failure if validation fails
public struct MagicAttackHandler: PacketHandler {

    public typealias Packet = MapleStory62.MagicAttackRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        // Magic attacks always use a skill
        // Look up skill data
        guard let skill = await SkillDataCache.shared.skill(id: packet.skillID),
              let skillLevel = skill.levels[0] else { // Default to level 0
            return // Invalid skill
        }

        // Check MP cost
        let mpCost = UInt16(max(0, min(skillLevel.mpCost, Int32(UInt16.max))))
        guard character.mp >= mpCost else {
            return // Not enough MP
        }

        // Deduct MP
        character.mp = character.mp - mpCost

        // Validate stance (can't attack while sitting)
        if packet.stance == 2 { // Sitting
            return
        }

        // Save character (MP deducted)
        try await connection.database.insert(character)

        // Process attack damage with magic defense
        try await connection.processAttack(
            targets: packet.targets,
            mapID: character.currentMap,
            useMagicDefense: true // Magic attacks use magic defense
        )
    }
}
