//
//  CharInfoRequestHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct CharInfoRequestHandler: PacketHandler {

    public typealias Packet = MapleStory83.CharInfoRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        guard let target = try await Character.fetch(
            packet.characterID,
            world: character.world,
            in: connection.database
        ) else {
            try await connection.send(ServerMessageNotification.notice(message: "Character not found."))
            return
        }

        try await connection.send(ServerMessageNotification.notice(
            message: "\(target.name.rawValue) Lv.\(target.level) \(target.job)"
        ))
    }
}
