//
//  SkillStatCalculator.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// Calculates stat modifications from skills/buffs.
public actor SkillStatCalculator {

    public static let shared = SkillStatCalculator()

    private init() {}

    /// Calculate modified stats for a character with all active buffs applied.
    public func calculateStats(
        base character: Character,
        buffs: [BuffState],
        skillCache: SkillDataCache
    ) async -> Character {
        // TODO: Apply actual stat modifications when Character has buffable stats
        // For now, return unmodified character
        // Future implementation would modify:
        // - speed (movement speed)
        // - jump (jump height)
        // - attack boosts
        // - defense boosts
        // - HP/MP boosts
        return character
    }

    /// Check if a character meets the requirements to use a skill.
    public func canUseSkill(
        _ skillID: UInt32,
        level: Int,
        by character: Character,
        skillCache: SkillDataCache
    ) async -> Bool {
        guard let skill = await skillCache.skill(id: skillID),
              let skillLevel = skill.levels[level] else {
            return false
        }

        // Check MP
        let mpCost = UInt16(max(0, min(skillLevel.mpCost, Int32(UInt16.max))))
        guard character.mp >= mpCost else {
            return false
        }

        // Check HP cost if any
        let hpCost = UInt16(max(0, min(skillLevel.hpCost, Int32(UInt16.max))))
        guard character.hp > hpCost else {
            return false
        }

        // Check if skill is on cooldown
        // TODO: Implement cooldown tracking

        // Additional skill-specific requirements would go here
        // (e.g., required weapon, required state, etc.)

        return true
    }
}
