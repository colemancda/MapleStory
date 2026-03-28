//
//  ReportHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct ReportHandler: PacketHandler {

    public typealias Packet = MapleStory83.ReportRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        _ = packet
        guard let _ = try await connection.character else { return }
        try await connection.send(ServerMessageNotification.notice(
            message: "Player report submitted."
        ))
    }
}
