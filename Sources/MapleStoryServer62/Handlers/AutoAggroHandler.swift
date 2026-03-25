//
//  AutoAggroHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct AutoAggroHandler: PacketHandler {

    public typealias Packet = MapleStory62.AutoAggroRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        guard let instance = await MapMobRegistry.shared.instance(objectID: packet.objectID),
              instance.mapID == character.currentMap else { return }

        // Ack the aggro ping so the client keeps monster control state in sync.
        try await connection.send(MoveMonsterResponse(
            objectID: packet.objectID,
            moveID: 0,
            useSkill: false,
            mp: 0,
            skillID: 0,
            skillLevel: 0
        ))
    }
}
