//
//  CharacterSkillRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// Registry for managing character skills
public actor CharacterSkillRegistry {

    public static let shared = CharacterSkillRegistry()

    private var skills: [Character.ID: [UInt32: CharacterSkill]] = [:]

    private init() {}

    // MARK: - Public Methods

    /// Get all skills for a character
    public func skills(for characterID: Character.ID) -> [UInt32: CharacterSkill] {
        return skills[characterID] ?? [:]
    }

    /// Get a specific skill for a character
    public func skill(_ skillID: UInt32, for characterID: Character.ID) -> CharacterSkill? {
        return skills[characterID]?[skillID]
    }

    /// Set a skill level
    public func setSkill(_ skillID: UInt32, level: UInt8, masteryLevel: UInt8, for characterID: Character.ID) {
        if skills[characterID] == nil {
            skills[characterID] = [:]
        }
        skills[characterID]?[skillID] = CharacterSkill(
            characterID: characterID,
            skillID: skillID,
            level: level,
            masteryLevel: masteryLevel
        )
    }

    /// Add skill level (for SP-based leveling)
    public func addSkillLevel(_ skillID: UInt32, for characterID: Character.ID) -> Bool {
        guard skills[characterID] != nil else {
            // New skill, start at level 1
            skills[characterID]?[skillID] = CharacterSkill(
                characterID: characterID,
                skillID: skillID,
                level: 1,
                masteryLevel: 10 // Default mastery level
            )
            return true
        }

        guard var skill = skills[characterID]?[skillID] else {
            // New skill
            skills[characterID]?[skillID] = CharacterSkill(
                characterID: characterID,
                skillID: skillID,
                level: 1,
                masteryLevel: 10
            )
            return true
        }

        // Check if can level up
        guard skill.level < skill.masteryLevel else {
            return false // Already at mastery level
        }

        skill.level += 1
        skills[characterID]?[skillID] = skill
        return true
    }

    /// Increase mastery level (for skill books)
    /// - Returns: New mastery level, or nil if failed
    @discardableResult
    public func addMasteryLevel(
        _ skillID: UInt32,
        for characterID: Character.ID
    ) -> UInt8? {
        guard skills[characterID] != nil else {
            return nil // Skill doesn't exist
        }

        guard var skill = skills[characterID]?[skillID] else {
            return nil // Skill doesn't exist
        }

        // Increase mastery level (typical 4th job skill: 10 -> 20 -> 30)
        guard skill.masteryLevel < 30 else {
            return nil // Already at max mastery level
        }

        skill.masteryLevel = min(30, skill.masteryLevel + 10)
        skills[characterID]?[skillID] = skill
        return skill.masteryLevel
    }

    /// Load skills from database
    public func loadSkills<Database: ModelStorage>(
        for characterID: Character.ID,
        database: Database
    ) async throws {
        let fetchQuery = CharacterSkill.fetch(
            predicate: "characterID == \(characterID.uuidString)"
        )
        let fetchedSkills = try await database.fetch(fetchQuery)

        var skillDict: [UInt32: CharacterSkill] = [:]
        for skill in fetchedSkills {
            skillDict[skill.skillID] = skill
        }
        skills[characterID] = skillDict
    }

    /// Save skills to database
    public func saveSkills<Database: ModelStorage>(
        for characterID: Character.ID,
        database: Database
    ) async throws {
        guard let skillDict = skills[characterID] else { return }

        for skill in skillDict.values {
            try await database.insert(skill)
        }
    }

    /// Clear skills for a character (e.g., on logout)
    public func clearSkills(for characterID: Character.ID) {
        skills[characterID] = nil
    }
}
