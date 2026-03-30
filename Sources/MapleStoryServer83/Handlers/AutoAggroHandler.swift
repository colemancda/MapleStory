//
//  AutoAggroHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct AutoAggroHandler: PacketHandler {

    public typealias Packet = MapleStory83.AutoAggroRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        guard let instance = await connection.mobInstance(objectID: packet.objectID),
              instance.mapID == character.currentMap else { return }

        try await connection.send(MoveMonsterResponseNotification(
            objectID: packet.objectID,
            moveID: 0,
            useSkills: false,
            currentMP: 0,
            skillID: 0,
            skillLevel: 0
        ))
    }
}
