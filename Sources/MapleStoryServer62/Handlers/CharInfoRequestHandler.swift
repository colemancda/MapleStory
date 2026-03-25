//
//  CharInfoRequestHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct CharInfoRequestHandler: PacketHandler {

    public typealias Packet = MapleStory62.CharInfoRequest

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
