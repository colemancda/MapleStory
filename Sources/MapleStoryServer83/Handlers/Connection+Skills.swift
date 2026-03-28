//
//  Connection+Skills.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

extension MapleStoryServer.Connection
where ClientOpcode == MapleStory83.ClientOpcode, ServerOpcode == MapleStory83.ServerOpcode {

    // MARK: - Skill Data

    func skillData(id: UInt32) async -> WzSkill? {
        await SkillDataCache.shared.skill(id: id)
    }

    func skillLevel(skillID: UInt32, level: Int) async -> WzSkillLevel? {
        await SkillDataCache.shared.level(skillID: skillID, level: level)
    }

    func canUseSkill(_ skillID: UInt32, level: Int, by character: MapleStory.Character) async -> Bool {
        await SkillStatCalculator.shared.canUseSkill(
            skillID,
            level: level,
            by: character,
            skillCache: SkillDataCache.shared
        )
    }

    // MARK: - Character Skills

    func characterSkill(_ skillID: UInt32, for characterID: Character.ID) async -> CharacterSkill? {
        await CharacterSkillRegistry.shared.skill(skillID, for: characterID)
    }

    func addSkillLevel(_ skillID: UInt32, for characterID: Character.ID) async -> UInt8? {
        await CharacterSkillRegistry.shared.addSkillLevel(skillID, for: characterID)
    }

    func addMasteryLevel(_ skillID: UInt32, for characterID: Character.ID) async -> UInt8? {
        await CharacterSkillRegistry.shared.addMasteryLevel(skillID, for: characterID)
    }

    func saveSkills(for characterID: Character.ID) async throws {
        try await CharacterSkillRegistry.shared.saveSkills(for: characterID, database: database)
    }

    // MARK: - Character Buffs

    func applyBuff(_ buff: BuffState, to characterID: Character.ID) async {
        await CharacterBuffRegistry.shared.applyBuff(buff, to: characterID)
    }

    func removeBuff(skillID: UInt32, from characterID: Character.ID) async {
        await CharacterBuffRegistry.shared.removeBuff(skillID: skillID, from: characterID)
    }

    func cleanupExpiredBuffs(for characterID: Character.ID) async {
        await CharacterBuffRegistry.shared.cleanupExpired(for: characterID)
    }

    // MARK: - Skill Macros

    func saveSkillMacros(_ macros: [SkillMacro], for characterID: Character.ID) async {
        await SkillMacroRegistry.shared.saveMacros(macros, for: characterID)
    }

    func persistSkillMacros(for characterID: Character.ID) async throws {
        try await SkillMacroRegistry.shared.saveMacros(for: characterID, database: database)
    }

    // MARK: - Keymap

    func saveKeymap(_ keymap: [KeymapEntry], for characterID: Character.ID) async {
        await KeymapRegistry.shared.saveKeymap(keymap, for: characterID)
    }

    func persistKeymap(for characterID: Character.ID) async throws {
        try await KeymapRegistry.shared.saveKeymap(for: characterID, database: database)
    }
}
