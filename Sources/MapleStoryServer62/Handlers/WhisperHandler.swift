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
            // TODO: Implement player search by name
            // Would need to query database for character by name
            // For now, just ignore
            return

        case 6: // Send whisper
            guard let message = packet.message else { return }

            // Send whisper packet
            try await connection.send(WhisperNotification(
                sender: character.name.rawValue,
                message: message
            ))

        default:
            return
        }
    }
}
