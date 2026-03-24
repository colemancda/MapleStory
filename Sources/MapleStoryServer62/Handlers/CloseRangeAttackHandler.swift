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
