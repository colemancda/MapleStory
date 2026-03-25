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

/// Handles whisper (private message) communication between players.
///
/// Whispers are private messages sent directly from one player to another.
/// They work across different maps and channels within the same world.
///
/// # Whisper Flow
///
/// 1. Player types: /w [name] [message] or uses whisper UI
/// 2. Client sends whisper request with recipient name and message
/// 3. Server looks up recipient by name
/// 4. Server validates recipient is online
/// 5. Server routes message to recipient's connection
/// 6. Recipient sees whisper in their chat window
///
/// # Whisper Features
///
/// - Cross-map communication
/// - Cross-channel communication (same world)
/// - Private (only sender and recipient see message)
/// - Sender sees delivery confirmation or error
///
/// # Error Responses
///
/// - Recipient not found (wrong name)
/// - Recipient offline
/// - Recipient has whispers blocked
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
