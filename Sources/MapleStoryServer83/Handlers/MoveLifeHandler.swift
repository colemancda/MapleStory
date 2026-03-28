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

        let notification = MoveMonsterNotification(
            objectID: packet.objectID,
            skillByte: packet.skillByte,
            skill: packet.skill,
            skillID: packet.skillID,
            skillLevel: packet.skillLevel,
            skillParam: packet.skillParam,
            startX: packet.startX,
            startY: packet.startY,
            movements: packet.movements
        )
        try await connection.broadcast(notification, map: mapID)

        let instance = await MapMobRegistry.shared.instance(objectID: packet.objectID)
        let response = MoveMonsterResponse(
            objectID: packet.objectID,
            moveID: packet.moveID,
            useSkill: packet.skillByte != 0,
            mp: 0,
            skillID: packet.skillID,
            skillLevel: packet.skillLevel
        )
        _ = instance
        try await connection.send(response)
    }
}
