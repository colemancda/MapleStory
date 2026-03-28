//
//  SkillEffectHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct SkillEffectHandler: PacketHandler {

    public typealias Packet = MapleStory83.SkillEffectRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
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
