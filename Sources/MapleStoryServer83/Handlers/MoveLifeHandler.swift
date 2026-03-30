//
//  MoveLifeHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct MoveLifeHandler: PacketHandler {

    public typealias Packet = MapleStory83.MoveLifeRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let mapID = await connection.mapID else { return }

        // Ignore movement from mobs not on this map.
        guard await connection.mobInstance(objectID: packet.objectID) != nil else { return }

        // Determine whether the activity byte represents an attack or skill cast.
        let rawActivity = Int(packet.skill) & 0x7F
        let isAttack = rawActivity >= 24 && rawActivity <= 41
        let isSkill  = rawActivity >= 42 && rawActivity <= 59

        var useSkillID: UInt8 = 0
        var useSkillLevel: UInt8 = 0

        if isSkill {
            // Validate the mob can actually use this skill (stub: always allow).
            useSkillID    = packet.skillID
            useSkillLevel = packet.skillLevel
        } else if isAttack {
            // Validate the attack position is within the allowed range (stub: always allow).
            _ = isAttack
        }

        // Suggest next skill for the mob (stub: send zeros).
        let nextSkillID: UInt8    = 0
        let nextSkillLevel: UInt8 = 0
        let mobMP: UInt16         = 0

        let response = MapleStory83.MoveMonsterResponseNotification(
            objectID: packet.objectID,
            moveID: packet.moveID,
            useSkills: packet.skillByte != 0,
            currentMP: mobMP,
            skillID: nextSkillID,
            skillLevel: nextSkillLevel
        )
        try await connection.send(response)

        let skillPossible = !isSkill && packet.skillByte == 0
        let notification = MapleStory83.MoveMonsterNotification(
            objectID: packet.objectID,
            unknown: 0,
            skillPossible: skillPossible,
            skill: useSkillID == 0 ? packet.skill : 0,
            skillID: useSkillID,
            skillLevel: useSkillLevel,
            pOption: packet.skillParam == 0 ? 0 : UInt16(packet.skillParam),
            startX: packet.startX,
            startY: packet.startY - 2,
            movements: packet.movements
        )
        try await connection.broadcast(notification, map: mapID)
    }
}
