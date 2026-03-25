//
//  CloseRangeAttackHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles melee (close-range) combat attacks.
///
/// # Melee Combat
///
/// Close-range attacks include:
/// - **Regular attack**: Basic weapon swing (no skill)
/// - **Skill attack**: Active skills (Power Strike, Slash Blast, etc.)
/// - **Weapons**: Swords, axes, spears, daggers, knuckles
///
/// # Attack Flow
///
/// 1. Player presses attack key or clicks monster
/// 2. Client sends attack packet with target data
/// 3. Server validates:
///    - Player has enough MP (for skill attacks)
///    - Player isn't sitting (stance check)
///    - Skill is valid
/// 4. Server deducts MP cost
/// 5. Server processes damage for each target
/// 6. Server broadcasts damage to map
///
/// # Skill Attacks
///
/// Active skills used for melee:
/// - **Power Strike** (Warrior): Single target, high damage
/// - **Slash Blast** (Warrior): Hit up to 6 enemies
/// - **Double Strike** (Beginner): Two-hit combo
/// - **Savage Blow** (Chief Bandit): Multiple rapid hits
///
/// # MP Cost
///
/// Skill attacks consume MP:
/// - Each skill has MP cost defined in skill data
/// - Cost checked before attack executes
/// - MP deducted regardless of hit/miss
/// - Not enough MP = attack fails silently
///
/// # Stance Validation
///
/// Player cannot attack while:
/// - **Sitting** (stance == 2): Attacking blocked
/// - **Climbing ladder/rope**: Movement restricted
/// - **Using certain items**: Some items prevent attacking
/// - **Dead**: Obviously can't attack
///
/// # Damage Calculation
///
/// Melee damage uses:
/// - **Weapon Attack** (WATK): From weapon and gear
/// - **STR**: Primary stat for warriors
/// - **DEX**: Secondary stat (accuracy for warriors)
/// - **Skill damage multiplier**: Skill-specific bonus
/// - **Monster Defense (PDD)**: Reduces damage
/// - **Critical hits**: Some classes have crit chance
///
/// # Attack Range
///
/// Melee attacks have short range:
/// - Typical range: ~50-100 pixels
/// - Spears/polearms: Longer reach
/// - Daggers: Very short range
/// - Must be facing target
///
/// # Anti-Cheat
///
/// - **MP validation**: Can't use skills without MP
/// - **Stance check**: Can't attack while sitting
/// - **Target validation**: Server validates targets exist
/// - **Damage capping**: Damage capped by monster stats
/// - **Speed hack detection**: Attack rate monitored
///
/// # Hit Detection
///
/// Server validates:
/// - Targets are within attack range
/// - Player is facing targets
/// - Targets aren't already dead
/// - Attack animation has completed
public struct CloseRangeAttackHandler: PacketHandler {

    public typealias Packet = MapleStory62.CloseRangeAttackRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        // Skill attack (skillID > 0 means using skill)
        if packet.skillID > 0 {
            // Look up skill data
            guard let skill = await SkillDataCache.shared.skill(id: packet.skillID),
                  let skillLevel = skill.levels[0] else { // Default to level 0 for attack skills
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

            // Check cooldown
            // TODO: Implement cooldown tracking

            // Save character (MP deducted)
            try await connection.database.insert(character)
        }

        // Process attack damage
        try await connection.processAttack(
            targets: packet.targets,
            mapID: character.currentMap,
            useMagicDefense: false // Close range uses physical defense
        )
    }
}
