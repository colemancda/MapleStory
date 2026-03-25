//
//  UseDoorHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct UseDoorHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseDoorRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let _ = try await connection.character else { return }
        guard packet.mode == 0 || packet.mode == 1 else { return }

        let direction = packet.mode == 0 ? "town -> field" : "field -> town"
        try await connection.send(ServerMessageNotification.notice(
            message: "Mystic door (\(direction)) is not available yet (oid \(packet.objectID))."
        ))
    }
}
