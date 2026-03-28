//
//  UseSkillBookHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct UseSkillBookHandler: PacketHandler {

    public typealias Packet = MapleStory83.UseSkillBookRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        guard packet.itemID / 1000 == 228 else { return }

        let skillBookData = await SkillBookDataCache.shared.skillBook(packet.itemID)
        guard let data = skillBookData else { return }

        let skillID = data.skillID
        let successRate = data.successRate

        guard let existingSkill = await CharacterSkillRegistry.shared.skill(skillID, for: character.id) else { return }
        guard existingSkill.masteryLevel < 30 else { return }

        let roll = Int.random(in: 1...100)
        let success = roll <= successRate

        let manipulator = InventoryManipulator()
        _ = try await manipulator.removeById(packet.itemID, quantity: 1, from: character)
        try await connection.database.insert(character)

        var newMasteryLevel = existingSkill.masteryLevel

        if success {
            if let updatedMastery = await CharacterSkillRegistry.shared.addMasteryLevel(skillID, for: character.id) {
                newMasteryLevel = updatedMastery
                try await CharacterSkillRegistry.shared.saveSkills(for: character.id, database: connection.database)
            }
        }

        try await connection.send(UseSkillBookNotification(
            skillID: skillID,
            currentLevel: existingSkill.level,
            masteryLevel: newMasteryLevel,
            success: success
        ))
    }
}
