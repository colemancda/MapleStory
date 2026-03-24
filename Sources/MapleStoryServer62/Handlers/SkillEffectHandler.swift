//
//  SkillEffectHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct SkillEffectHandler: PacketHandler {

    public typealias Packet = MapleStory62.SkillEffectRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Broadcast skill effect to other players on the same map
        guard let mapID = await connection.mapID else { return }

        try await connection.broadcast(SkillEffectNotification(
            characterID: character.index,
            skillID: packet.skillID,
            level: packet.level,
            flags: packet.flags,
            speed: packet.speed
        ), map: mapID)
    }
}
