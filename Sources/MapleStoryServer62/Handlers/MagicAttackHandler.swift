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
