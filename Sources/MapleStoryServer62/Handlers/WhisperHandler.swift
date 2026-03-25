//
//  WhisperHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct WhisperHandler: PacketHandler {

    public typealias Packet = MapleStory62.WhisperRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        switch packet.mode {
        case 5: // Find player
            try await connection.send(ServerMessageNotification.notice(
                message: "\(packet.target) is not online (player lookup not wired yet)."
            ))
            return

        case 6: // Send whisper
            guard let message = packet.message else { return }

            // Cross-session target dispatch is not wired yet, so mirror to sender.
            try await connection.send(WhisperNotification(
                sender: character.name.rawValue,
                message: message
            ))

        default:
            return
        }
    }
}
