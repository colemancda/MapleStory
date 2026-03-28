//
//  SpecialMoveHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct SpecialMoveHandler: PacketHandler {

    public typealias Packet = MapleStory83.SpecialMoveRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else {
            return
        }

        guard let skill = await connection.skillData(id: packet.skillID),
              let skillLevel = skill.levels[Int(packet.skillLevel)] else {
            return
        }

        guard await connection.canUseSkill(packet.skillID, level: Int(packet.skillLevel), by: character) else {
            return
        }

        let mpCost = UInt16(max(0, min(skillLevel.mpCost, Int32(UInt16.max))))
        character.mp = character.mp - mpCost

        let hpCost = UInt16(max(0, min(skillLevel.hpCost, Int32(UInt16.max))))
        if hpCost > 0 {
            character.hp = character.hp - hpCost
        }

        let isBuff = skillLevel.time > 0

        if packet.skillID == 2311002 {
            try await createMysticDoor(
                for: character,
                skillLevel: Int(packet.skillLevel),
                connection: connection
            )
        } else if isBuff {
            let duration = TimeInterval(skillLevel.time)
            let buff = BuffState(
                skillID: packet.skillID,
                level: Int(packet.skillLevel),
                duration: duration
            )
            await connection.applyBuff(buff, to: character.id)

            let buffStats = calculateBuffStats(skillID: packet.skillID, level: skillLevel)

            try await connection.send(GiveBuffNotification(
                skillID: packet.skillID,
                level: packet.skillLevel,
                duration: UInt32(skillLevel.time),
                buffStats: buffStats
            ))
        }

        try await connection.database.insert(character)
    }

    private func calculateBuffStats(skillID: UInt32, level: WzSkillLevel) -> UInt32 {
        var buffStats: UInt32 = 0
        if level.speed > 0 { buffStats |= 1 << 0 }
        if level.jump > 0  { buffStats |= 1 << 1 }
        if level.x > 0     { buffStats |= 1 << 2 }
        if level.y > 0     { buffStats |= 1 << 3 }
        if level.z > 0     { buffStats |= 1 << 4 }
        if level.w > 0     { buffStats |= 1 << 5 }
        return buffStats
    }

    private func createMysticDoor<Socket: MapleStorySocket, Database: ModelStorage>(
        for character: MapleStory.Character,
        skillLevel: Int,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let mapData = await connection.mapData(id: character.currentMap) else {
            try await connection.send(ServerMessageNotification.notice(message: "Cannot create door here."))
            return
        }

        let townMapID = Map.ID(rawValue: mapData.info.returnMap)
        guard let townMapData = await connection.mapData(id: townMapID) else {
            return
        }

        let doorPortals = townMapData.portals.filter { $0.type == 6 }
        guard let (portalIndex, _) = doorPortals.enumerated().first(where: { $0.element.type == 6 }) else {
            try await connection.send(ServerMessageNotification.notice(message: "No door portals available in town."))
            return
        }

        guard let charPosition = await connection.playerPosition(for: character.id) else {
            try await connection.send(ServerMessageNotification.notice(message: "Cannot determine your position."))
            return
        }

        let duration = 300.0 + TimeInterval(skillLevel) * 10.0

        let door = Door(
            ownerID: character.id,
            townMapID: townMapID,
            townPortalID: UInt8(portalIndex),
            fieldMapID: character.currentMap,
            fieldPosition: Position(x: charPosition.x, y: charPosition.y),
            duration: duration
        )

        await connection.registerDoor(door)
    }
}
