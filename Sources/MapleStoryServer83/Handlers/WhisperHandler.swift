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
            // Flag 0x09: find result. channelOrSuccess = 0 means not found.
            let result = WhisperNotification(
                flag: 0x09,
                characterName: packet.target,
                channelOrSuccess: 0,
                fromAdmin: nil,
                message: nil
            )
            try await connection.send(result)

        case 6: // Send whisper
            guard let message = packet.message else { return }
            guard message.count <= 127 else { return }

            // Flag 0x0A: whisper sent result (name, success byte).
            // 1 = delivered, 0 = target not found.
            // Cross-session delivery not yet wired — report failure to sender.
            let result = WhisperNotification(
                flag: 0x0A,
                characterName: packet.target,
                channelOrSuccess: 0,
                fromAdmin: nil,
                message: nil
            )
            try await connection.send(result)
            _ = character
            _ = message

        default:
            break
        }
    }
}
