//
//  UseSkillBookHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct UseSkillBookHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseSkillBookRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Skill books are USE inventory items with IDs starting at 228
        guard packet.itemID / 1000 == 228 else {
            return // Not a valid skill book
        }

        // Look up skill book data
        let skillBookData = await SkillBookDataCache.shared.skillBook(packet.itemID)
        guard let data = skillBookData else {
            return // Invalid skill book
        }

        let skillID = data.skillID
        let successRate = data.successRate

        // Check if character has the skill
        guard let existingSkill = await CharacterSkillRegistry.shared.skill(skillID, for: character.id) else {
            // Character doesn't have this skill yet
            // Skill books can only be used on known skills
            return
        }

        // Check if can increase mastery level (max is 30)
        guard existingSkill.masteryLevel < 30 else {
            return // Already at max mastery
        }

        // Roll for success
        let roll = Int.random(in: 1...100)
        let success = roll <= successRate

        // Consume the skill book
        let manipulator = InventoryManipulator()
        _ = try await manipulator.removeById(packet.itemID, quantity: 1, from: character)

        // Save updated inventory
        try await connection.database.insert(character)

        var newMasteryLevel = existingSkill.masteryLevel

        if success {
            // Increase mastery level by 10
            if let updatedMastery = await CharacterSkillRegistry.shared.addMasteryLevel(skillID, for: character.id) {
                newMasteryLevel = updatedMastery

                // Save skill to database
                try await CharacterSkillRegistry.shared.saveSkills(for: character.id, database: connection.database)
            }
        }

        // Send skill book result notification
        try await connection.send(UseSkillBookNotification(
            skillID: skillID,
            currentLevel: existingSkill.level,
            masteryLevel: newMasteryLevel,
            success: success
        ))
    }
}

// MARK: - Skill Book Data Cache

/// Cache for skill book data
public actor SkillBookDataCache {

    public static let shared = SkillBookDataCache()

    private var skillBooks: [UInt32: SkillBookData] = [:]

    private init() {
        // Initialize with common skill books
        // Note: This runs synchronously in init
        var books: [UInt32: SkillBookData] = [:]

        // Hero (Warrior 4th job)
        books[2_280_001] = SkillBookData(skillID: 112_000_4, successRate: 50) // Hero's Valor (10 -> 20)
        books[2_280_002] = SkillBookData(skillID: 112_000_4, successRate: 50) // Hero's Valor (20 -> 30)
        books[2_280_003] = SkillBookData(skillID: 112_100_1, successRate: 50) // Brandish
        books[2_280_004] = SkillBookData(skillID: 112_100_1, successRate: 50) // Brandish
        books[2_280_008] = SkillBookData(skillID: 112_100_6, successRate: 50) // Rush

        // Paladin (Warrior 4th job)
        books[2_280_019] = SkillBookData(skillID: 122_100_4, successRate: 50) // Holy Charge
        books[2_280_020] = SkillBookData(skillID: 122_100_4, successRate: 50) // Holy Charge
        books[2_280_021] = SkillBookData(skillID: 122_100_5, successRate: 50) // Divine Charge
        books[2_280_022] = SkillBookData(skillID: 122_100_5, successRate: 50) // Divine Charge

        // Fire/Poison Arch Mage (Magician 4th job)
        books[2_280_039] = SkillBookData(skillID: 212_100_3, successRate: 50) // Fire Demon
        books[2_280_040] = SkillBookData(skillID: 212_100_3, successRate: 50) // Fire Demon
        books[2_280_041] = SkillBookData(skillID: 212_100_4, successRate: 50) // Paralyze
        books[2_280_042] = SkillBookData(skillID: 212_100_4, successRate: 50) // Paralyze

        // Ice/Lightning Arch Mage (Magician 4th job)
        books[2_280_043] = SkillBookData(skillID: 222_100_3, successRate: 50) // Ice Demon
        books[2_280_044] = SkillBookData(skillID: 222_100_3, successRate: 50) // Ice Demon
        books[2_280_045] = SkillBookData(skillID: 222_100_4, successRate: 50) // Chain Lightning
        books[2_280_046] = SkillBookData(skillID: 222_100_4, successRate: 50) // Chain Lightning

        // Bowmaster (Bowman 4th job)
        books[2_280_057] = SkillBookData(skillID: 312_100_4, successRate: 50) // Hurricane
        books[2_280_058] = SkillBookData(skillID: 312_100_4, successRate: 50) // Hurricane
        books[2_280_059] = SkillBookData(skillID: 312_100_6, successRate: 50) // Bow Expert
        books[2_280_060] = SkillBookData(skillID: 312_100_6, successRate: 50) // Bow Expert

        // Night Lord (Thief 4th job)
        books[2_280_085] = SkillBookData(skillID: 412_100_6, successRate: 50) // Shadow Claw
        books[2_280_086] = SkillBookData(skillID: 412_100_6, successRate: 50) // Shadow Claw
        books[2_280_087] = SkillBookData(skillID: 412_100_9, successRate: 50) // Ninja Storm
        books[2_280_088] = SkillBookData(skillID: 412_100_9, successRate: 50) // Ninja Storm

        // Shadower (Thief 4th job)
        books[2_280_089] = SkillBookData(skillID: 422_100_5, successRate: 50) // Assassination
        books[2_280_090] = SkillBookData(skillID: 422_100_5, successRate: 50) // Assassination
        books[2_280_091] = SkillBookData(skillID: 422_100_6, successRate: 50) // Boomerang Step
        books[2_280_092] = SkillBookData(skillID: 422_100_6, successRate: 50) // Boomerang Step

        self.skillBooks = books
    }

    public func skillBook(_ itemID: UInt32) -> SkillBookData? {
        return skillBooks[itemID]
    }
}

/// Skill book data
public struct SkillBookData: Sendable {
    public let skillID: UInt32
    public let successRate: Int // 0-100

    public init(skillID: UInt32, successRate: Int) {
        self.skillID = skillID
        self.successRate = successRate
    }
}
