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

        // Check if character can use this skill (has enough MP/HP, not on cooldown, etc.)
        let canUse = await SkillStatCalculator.shared.canUseSkill(
            packet.skillID,
            level: Int(packet.skillLevel),
            by: character,
            skillCache: SkillDataCache.shared
        )

        guard canUse else {
            return // Cannot use skill (not enough MP/HP, cooldown, etc.)
        }

        // Deduct MP cost
        let mpCost = UInt16(max(0, min(skillLevel.mpCost, Int32(UInt16.max))))
        character.mp = character.mp - mpCost

        // Deduct HP cost if any
        let hpCost = UInt16(max(0, min(skillLevel.hpCost, Int32(UInt16.max))))
        if hpCost > 0 {
            character.hp = character.hp - hpCost
        }

        // Check if this is a buff skill
        let isBuff = skillLevel.time > 0

        // Special handling for Mystic Door (2311002)
        if packet.skillID == 2311002 {
            // Mystic Door skill - create a door
            try await createMysticDoor(
                for: character,
                skillLevel: Int(packet.skillLevel),
                connection: connection
            )
        } else if isBuff {
            // Apply buff
            let duration = TimeInterval(skillLevel.time)
            let buff = BuffState(
                skillID: packet.skillID,
                level: Int(packet.skillLevel),
                duration: duration
            )
            await CharacterBuffRegistry.shared.applyBuff(buff, to: character.id)

            // Calculate buff stat mask
            let buffStats = calculateBuffStats(skillID: packet.skillID, level: skillLevel)

            // Send buff notification to client
            try await connection.send(GiveBuffNotification(
                skillID: packet.skillID,
                level: packet.skillLevel,
                duration: UInt32(skillLevel.time),
                buffStats: buffStats
            ))

            // Note: Stat modifications are calculated but not directly applied
            // to Character model since it doesn't have buff-specific stat fields.
            // Buff effects are handled by the client via the buff packet.

        } else {
            // Attack skill - damage calculation
            // Attack skills require parsing additional packet data for mob targets
            // Damage calculation would use skill.level.damage, .attackCount, .mobCount
            // This is a significant feature requiring mob target parsing and broadcast
        }

        // Save character (MP was deducted)
        try await connection.database.insert(character)
    }

    /// Calculate buff stat mask for packet encoding.
    /// In v62, buff effects are encoded as bitflags.
    private func calculateBuffStats(skillID: UInt32, level: WzSkillLevel) -> UInt32 {
        var buffStats: UInt32 = 0

        // Basic buff stat flags (simplified - v62 has more complex encoding)
        if level.speed > 0 { buffStats |= 1 << 0 }  // Speed
        if level.jump > 0 { buffStats |= 1 << 1 }  // Jump
        if level.x > 0 { buffStats |= 1 << 2 }     // Watk (for some skills)
        if level.y > 0 { buffStats |= 1 << 3 }     // Wdef (for some skills)
        if level.z > 0 { buffStats |= 1 << 4 }     // Matk (for some skills)
        if level.w > 0 { buffStats |= 1 << 5 }     // Mdef (for some skills)

        // Skill-specific mappings would go here
        // For now, return a basic mask

        return buffStats
    }

    /// Create a Mystic Door for the character
    private func createMysticDoor<Socket: MapleStorySocket, Database: ModelStorage>(
        for character: MapleStory.Character,
        skillLevel: Int,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Get current map data to find return map (town)
        guard let mapData = await MapDataCache.shared.map(id: character.currentMap) else {
            try await connection.send(ServerMessageNotification.notice(
                message: "Cannot create door here."
            ))
            return
        }

        // Find a free door portal (type 6) in the town
        let townMapID = mapData.returnMap
        guard let townMapData = await MapDataCache.shared.map(id: townMapID) else {
            return
        }

        // Find first available door portal (type 6)
        let doorPortals = townMapData.portals.filter { $0.type == 6 }
        guard let portal = doorPortals.first else {
            try await connection.send(ServerMessageNotification.notice(
                message: "No door portals available in town."
            ))
            return
        }

        // Get door duration based on skill level
        // Level 1: 300 seconds (5 minutes), increases with level
        let baseDuration: TimeInterval = 300.0
        let duration = baseDuration + TimeInterval(skillLevel * 10.0)

        // Create the door
        let door = Door(
            ownerID: character.id,
            townMapID: townMapID,
            townPortalID: portal.id,
            fieldMapID: character.currentMap,
            fieldPosition: Position(x: character.x, y: character.y),
            duration: duration
        )

        // Register the door
        await DoorRegistry.shared.register(door)

        // Log for debugging
        print("[Door] Created door for character \(character.name) " +
              "from \(door.fieldMapID) to \(door.townMapID), " +
              "duration: \(duration)s")

        // Note: Client would need to receive door spawn packets
        // This would require sending SpawnDoorNotification or similar packets
        // to party members showing the door location
    }
}
