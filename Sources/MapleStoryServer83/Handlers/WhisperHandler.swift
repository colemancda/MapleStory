//
//  WhisperHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct WhisperHandler: PacketHandler {

    public typealias Packet = MapleStory83.WhisperRequest

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

            try await connection.send(WhisperNotification(
                sender: character.name.rawValue,
                message: message
            ))

        default:
            return
        }
    }
}
