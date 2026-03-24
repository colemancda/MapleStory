//
//  SpecialMoveHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct SpecialMoveHandler: PacketHandler {

    public typealias Packet = MapleStory62.SpecialMoveRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else {
            return
        }

        // Look up skill data
        guard let skill = await SkillDataCache.shared.skill(id: packet.skillID),
              let skillLevel = skill.levels[Int(packet.skillLevel)] else {
            return // Invalid skill or level
        }

        // Check if character has enough MP
        let mpCost = UInt16(max(0, min(skillLevel.mpCost, Int32(UInt16.max))))
        guard character.mp >= mpCost else {
            return // Not enough MP
        }

        // Deduct MP
        character.mp = character.mp - mpCost

        // Check if this is a buff skill
        let isBuff = skillLevel.time > 0

        if isBuff {
            // Apply buff
            let duration = TimeInterval(skillLevel.time)
            let buff = BuffState(
                skillID: packet.skillID,
                level: Int(packet.skillLevel),
                duration: duration
            )
            await CharacterBuffRegistry.shared.applyBuff(buff, to: character.id)

            // TODO: Apply buff stat effects to character
            // TODO: Send buff packet to client

        } else {
            // Attack skill - damage calculation
            // TODO: Implement skill damage calculation
            // TODO: Handle mob targets from packet data
            // TODO: Broadcast skill animation to map
        }

        // Save character (MP was deducted)
        try await connection.database.insert(character)
    }
}
