//
//  SpouseChatHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct SpouseChatHandler: PacketHandler {

    public typealias Packet = MapleStory62.SpouseChatRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        guard character.isMarried else {
            try await connection.send(ServerMessageNotification.notice(message: "You are not married."))
            return
        }

        // Spouse routing is not wired yet; mirror locally so the sender gets immediate feedback.
        try await connection.send(WhisperNotification(
            sender: "[Spouse->\(packet.recipient)] \(character.name.rawValue)",
            message: packet.message
        ))
    }
}
