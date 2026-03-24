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
