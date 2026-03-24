//
//  MoveLifeHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct MoveLifeHandler: PacketHandler {

    public typealias Packet = MapleStory62.MoveLifeRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let mapID = connection.mapID else { return }

        // Relay movement to all other clients on the map.
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

        // Acknowledge to the controller (mob MP = 0 until MP tracking is wired up).
        let instance = await MapMobRegistry.shared.instance(objectID: packet.objectID)
        let response = MoveMonsterResponse(
            objectID: packet.objectID,
            moveID: packet.moveID,
            useSkill: packet.skillByte != 0,
            mp: 0,
            skillID: packet.skillID,
            skillLevel: packet.skillLevel
        )
        _ = instance // reserved for future MP tracking
        try await connection.send(response)
    }
}
