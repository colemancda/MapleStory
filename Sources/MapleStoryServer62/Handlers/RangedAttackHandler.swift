//
//  RangedAttackHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles ranged physical attacks (bows, crossbows, throwing stars).
///
/// # Ranged Combat
///
/// Ranged attacks include:
/// - **Regular shot**: Basic bow/crossbow shot
/// - **Skill shots**: Arrow Bomb, Iron Arrow, Strafe, etc.
/// - **Throwing stars**: Assassin attacks (Lucky Seven, Drain, etc.)
/// - **Ammunition**: Consumes arrows or stars
///
/// # Weapons
///
/// **Bows**:
/// - Range: ~300-400 pixels
/// - Attack speed: Normal/Fast
/// - Stats: DEX primary, STR secondary
/// - Arrows required
///
/// **Crossbows**:
/// - Range: ~300-400 pixels
/// - Attack speed: Slow
/// - Stats: DEX primary, STR secondary
/// - Arrows required
///
/// **Claws** (Throwing stars):
/// - Range: ~200-300 pixels
/// - Attack speed: Fast
/// - Stats: LUK primary, DEX secondary
/// - Throwing stars required
///
/// # Attack Flow
///
/// 1. Player targets monster and attacks
/// 2. Client sends attack packet with targets
/// 3. Server validates:
///    - MP cost (for skill attacks)
///    - Ammunition count (TODO: not yet enforced)
///    - Stance (not sitting)
/// 4. Server deducts MP and ammunition (TODO)
/// 5. Server calculates damage using PDD (physical defense)
/// 6. Server broadcasts damage to map
///
/// # Skill Examples
///
/// **Bowman Skills**:
/// - **Arrow Bomb**: Hits up to 6 mobs, stuns
/// - **Iron Arrow**: Pierces through multiple enemies
/// - **Strafe**: 4 shots at once
/// - **Arrow Rain**: Area-of-effect around player
/// - **Mortal Blow**: Close-range finishing move
///
/// **Assassin Skills**:
/// - **Lucky Seven**: 2 throws, LUK-based damage
/// - **Drain**: HP recovery based on damage
/// - **Avenger**: Throwing star that hits multiple targets
/// - **Shadow Partner**: Summon that mimics attacks
///
/// # Ammunition System
///
/// **Arrows**:
/// - Stored in USE inventory
/// - Consumed 1 per shot (unless using Soul Arrow)
/// - Arrow types: Bronze, Steel, Diamond, etc.
/// - **Soul Arrow** skill: Doesn't consume arrows
///
/// **Throwing Stars**:
/// - Stored in USE inventory
/// - Set amounts: 500, 800, 1000, etc.
/// - Consumed per throw (unless using Shadow Claw)
/// - Star types: Subi, Tobbi, Steely, Ilbi, Crystal Ilbi
/// - **Shadow Claw** skill: Doesn't consume stars
///
/// # Damage Calculation
///
/// Ranged damage formula:
/// ```
/// Damage = (WeaponAttack × StatMultiplier + SecondaryStat) × SkillMultiplier - MonsterPDD
///
/// Bowman:
///   Primary: DEX
///   Secondary: STR
///   Multiplier: 3.4 × DEX + STR
///
/// Assassin:
///   Primary: LUK
///   Secondary: DEX
///   Multiplier: 3.6 × LUK (for Lucky Seven)
/// ```
///
/// # Critical Hits
///
/// Ranged classes have critical hit chance:
/// - **Bowmen**: Critical Shot (passive, +50% crit chance)
/// - **Assassins**: No built-in crit (needs equipment)
/// - Crit damage: +50% damage
/// - Can stack with skill effects
///
/// # Anti-Cheat
///
/// - **MP validation**: Can't use skills without MP
/// - **Ammo validation**: Can't shoot without ammo (TODO)
/// - **Range check**: Can't hit monsters outside weapon range
/// - **Speed check**: Can't attack faster than weapon speed
/// - **Damage cap**: Damage capped to prevent hacking
///
/// # Ammunition Notes
///
/// Currently not enforced:
/// - Arrows and stars should be consumed
/// - Soul Arrow/Shadow Claw should prevent consumption
/// - This will be implemented in future updates
///
/// # Side Effects
///
/// - **Database**: Saves character (MP deducted)
/// - **Broadcasts**: Damage notifications to map (via processAttack)
/// - **Ammo**: Should consume ammunition but currently does not
public struct RangedAttackHandler: PacketHandler {

    public typealias Packet = MapleStory62.RangedAttackRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        // Ranged attacks use skills (arrow rain, mortal blow, etc.)
        if packet.skillID > 0 {
            // Look up skill data
            guard let skill = await SkillDataCache.shared.skill(id: packet.skillID),
                  let skillLevel = skill.levels[0] else {
                return // Invalid skill
            }

            // Check MP cost
            let mpCost = UInt16(max(0, min(skillLevel.mpCost, Int32(UInt16.max))))
            guard character.mp >= mpCost else {
                return // Not enough MP
            }

            // Deduct MP
            character.mp = character.mp - mpCost

            // Validate stance
            if packet.stance == 2 { // Sitting
                return
            }

            // Save character
            try await connection.database.insert(character)
        }

        // TODO: Consume ammo (stars/arrows) from inventory
        // For now, ranged attacks don't consume ammo

        // Process attack damage
        // Ranged attacks use physical defense
        try await connection.processAttack(
            targets: packet.targets,
            mapID: character.currentMap,
            useMagicDefense: false
        )
    }
}
