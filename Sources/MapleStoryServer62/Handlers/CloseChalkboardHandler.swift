//
//  CloseChalkboardHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct CloseChalkboardHandler: PacketHandler {

    public typealias Packet = MapleStory62.CloseChalkboardRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        _ = packet
        guard let character = try await connection.character else { return }
        try await connection.broadcast(
            ChalkboardNotification.close(characterID: character.index),
            map: character.currentMap
        )
    }
}
