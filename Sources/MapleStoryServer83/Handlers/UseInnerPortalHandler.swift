//
//  UseInnerPortalHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct UseInnerPortalHandler: PacketHandler {

    public typealias Packet = MapleStory83.UseInnerPortalRequest

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
