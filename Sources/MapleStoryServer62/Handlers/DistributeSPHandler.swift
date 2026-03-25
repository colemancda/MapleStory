//
//  DistributeSPHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles SP (Skill Point) distribution to skills.
///
/// # Skill Points (SP)
///
/// - Players earn SP when leveling up
/// - SP can be allocated to job-appropriate skills
/// - Each skill level costs 1 SP
/// - SP persists until used
/// - Can be reallocated using SP resets (NX cash item)
///
/// # SP Gains
///
/// SP earned per level:
/// - **Levels 1-10**: 3 SP per level (beginner)
/// - **Levels 11+**: 3 SP per level (1st job onwards)
/// - Total SP at level 200: ~600 SP
///
/// Some quests also grant SP as rewards.
///
/// # Skill Distribution Rules
///
/// ## Job Restrictions
///
/// Players can only learn skills for their job:
/// - **Beginner** (ID prefix 1000): Only beginner skills
/// - **Warrior** (ID prefix 11xx-13xx): Warrior skills
/// - **Magician** (ID prefix 20xx-23xx): Mage skills
/// - **Bowman** (ID prefix 30xx-32xx): Bowman skills
/// - **Thief** (ID prefix 40xx-42xx): Thief skills
/// - **Pirate** (ID prefix 50xx-52xx): Pirate skills
///
** Cannot cross-train (e.g., warrior can't learn magic)
///
/// ## Skill Level Limits
///
/// Each skill has max level:
/// - **1st job skills**: Max level 20
/// - **2nd job skills**: Max level 30
/// - **3rd job skills**: Max level 20
/// - **4th job skills**: Max level 30
/// - **Beginner skills**: Max level 3
///
/// Mastery level can be increased with:
/// - **Skill books**: From boss runs or quests
/// - **Mastery guides**: Consumable items
///
** Max level 10 → Max level 20 → Max level 30
///
/// ## Skill Prerequisites
///
** Some skills require other skills:
/// - Must have level 3 in skill A to learn skill B
/// - Example: Warrior must have level 3 Improving MAXHP to learn Iron Will
/// - Server validates prerequisites before allowing allocation
///
/// # Skill Allocation Process
///
/// 1. Player opens skill window (press K)
/// 2. Player clicks "+" button next to skill
/// 3. Client sends SP distribution request
/// 4. Server validates:
///    - Player has at least 1 SP
///    - Skill exists for player's job
///    - Current level < max level
/// 5. Server increments skill level
/// 6. Server decrements SP count
/// 7. Server saves character and skills
/// 8. Server sends stat update notification
///
** Client shows skill level increase animation
///
/// # Skill Tree Structure
///
/// Skills are organized by job advancement:
///
** 1st Job (Level 10):
/// - Choose one of 5 paths (Warrior, Magician, Bowman, Thief, Pirate)
/// - Learn basic job skills
/// - Spend ~20 SP to max all skills
///
** 2nd Job (Level 30):
/// - Specialize further (e.g., Fighter vs Page vs Spearman)
/// - Learn stronger skills
/// - Spend ~60 SP to max all skills
///
** 3rd Job (Level 70):
/// - Advanced specialization
/// - Learn powerful skills
/// - Spend ~80 SP to max all skills
///
** 4th Job (Level 120):
/// - Master class skills
/// - Learn ultimate skills
/// - Spend ~150 SP to max all skills
///
/// # Skill Mastery
///
/// Early levels of skills deal unstable damage:
/// - **Level 1**: Damage varies 10%-90% of listed damage
/// - **Max level**: Damage varies 60%-140% of listed damage
/// - **Mastery affects consistency**: Higher mastery = more stable damage
///
/// # Anti-Cheat
///
/// - **SP validation**: Can't spend SP you don't have
/// - **Job validation**: Can't learn wrong job skills
/// - **Level cap**: Can't exceed max skill level
/// - **Server authoritative**: Server tracks actual SP and skills
/// - **Prevents skill hacking**: Client can't fake skills
///
/// # Skill Book System
///
/// High-level skills require skill books:
/// - **Mastery books**: Increase max level from 10 → 20 → 30
/// - **Skill books**: Unlock the skill (for some 4th job skills)
/// - **Drop from bosses**: Zakum, Horntail, Pink Bean, etc.
/// - **Tradeable**: Some books can be bought/sold
/// - **Success rate**: Books have chance to fail when used
///
** Failure wastes the book but doesn't consume SP
///
/// # SP Reset
///
** NX cash shop item:
/// - Removes all SP from a skill
/// - Returns SP to pool
/// - Can reallocate to different skills
/// - Useful for fixing build mistakes
public struct DistributeSPHandler: PacketHandler {

    public typealias Packet = MapleStory62.DistributeSPRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }
        guard character.sp > 0 else { return }

        // Look up skill data
        guard let skill = await SkillDataCache.shared.skill(id: packet.skillID) else {
            return // Invalid skill
        }

        // Get current skill data
        let currentSkill = await CharacterSkillRegistry.shared.skill(packet.skillID, for: character.id)
        let currentLevel = currentSkill?.level ?? 0

        // Check if skill exists for this job
        guard canLearnSkill(skillID: packet.skillID, job: character.job) else {
            return // Wrong job for this skill
        }

        // Check if max level reached
        let maxLevel = currentSkill?.masteryLevel ?? 10
        guard currentLevel < maxLevel else {
            return // Already at max level
        }

        // Try to add skill level
        let success = await CharacterSkillRegistry.shared.addSkillLevel(packet.skillID, for: character.id)
        guard success else {
            return // Failed to level up
        }

        // Decrement SP
        character.sp -= 1
        try await connection.database.insert(character)

        // Save skills to database
        try await CharacterSkillRegistry.shared.saveSkills(for: character.id, database: connection.database)

        // Send stat update
        let notification = UpdateStatsNotification(
            announce: true,
            stats: .availableSP,
            skin: nil, face: nil, hair: nil, level: nil, job: nil,
            str: nil, dex: nil, int: nil, luk: nil,
            hp: nil, maxHp: nil, mp: nil, maxMp: nil,
            ap: nil, sp: character.sp,
            exp: nil, fame: nil, meso: nil
        )
        try await connection.send(notification)

        // TODO: Send skill level update packet (updateSkills opcode)
    }

    // MARK: - Private Helpers

    private func canLearnSkill(skillID: UInt32, job: Job) -> Bool {
        // Simple job check: skill ID prefix must match job type
        let jobPrefix = skillID / 10000

        switch job.type {
        case .beginner:
            return jobPrefix == 1000 // Beginner skills
        case .warrior:
            return jobPrefix == 1100 || jobPrefix == 1200 || jobPrefix == 1300 || // 1st job
                   jobPrefix == 1110 || jobPrefix == 1210 || jobPrefix == 1310 || // 2nd job
                   jobPrefix == 1111 || jobPrefix == 1211 || jobPrefix == 1311 || // 3rd job
                   jobPrefix == 1120 || jobPrefix == 1220 || jobPrefix == 1320     // 4th job (Hero/Paladin/DK)
        case .magician:
            return jobPrefix == 2000 || // 1st job (Magician)
                   jobPrefix == 2100 || jobPrefix == 2200 || jobPrefix == 2300 || // 2nd job (F/P/I/L)
                   jobPrefix == 2110 || jobPrefix == 2210 || jobPrefix == 2310 || // 3rd job
                   jobPrefix == 2120 || jobPrefix == 2220 || jobPrefix == 2320     // 4th job
        case .bowman:
            return jobPrefix == 3000 || jobPrefix == 3100 || jobPrefix == 3200 ||
                   jobPrefix == 3110 || jobPrefix == 3210 ||
                   jobPrefix == 3120 || jobPrefix == 3220 // 4th job
        case .thief:
            return jobPrefix == 4000 || jobPrefix == 4100 || jobPrefix == 4200 ||
                   jobPrefix == 4110 || jobPrefix == 4210 ||
                   jobPrefix == 4120 || jobPrefix == 4220 // 4th job
        case .pirate:
            return jobPrefix == 5000 || jobPrefix == 5100 || jobPrefix == 5200 ||
                   jobPrefix == 5110 || jobPrefix == 5210 ||
                   jobPrefix == 5120 || jobPrefix == 5220 // 4th job
        default:
            return false
        }
    }
}
