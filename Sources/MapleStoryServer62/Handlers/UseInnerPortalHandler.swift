//
//  UseInnerPortalHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct UseInnerPortalHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseInnerPortalRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        _ = packet
        guard let _ = try await connection.character else { return }

        // Inner portal pathing requires per-map scripted portal tables.
        try await connection.send(ServerMessageNotification.notice(
            message: "This inner portal is not available yet."
        ))
    }
}
