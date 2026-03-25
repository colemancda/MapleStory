//
//  MessengerHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles Maple Messenger (buddy chat) operations.
///
/// The Maple Messenger is a small group chat feature (up to 3 players)
/// that allows friends to communicate across different maps and channels.
/// It differs from regular whisper (private chat) in that multiple people
/// can be in the same messenger at once.
///
/// # Messenger Operations
///
/// - **Join**: Invite a friend to the messenger
/// - **Leave**: Exit the messenger group
/// - **Message**: Send a message to all messenger members
/// - **Invite**: Invite another player
///
/// # Messenger vs Party Chat
///
/// | Feature | Messenger | Party Chat |
/// |---------|-----------|------------|
/// | Max members | 3 | 6 |
/// | Requires party | No | Yes |
/// | Cross-channel | Yes | Yes |
/// | Persistent | Session | Until party disbands |
///
/// # Implementation Status
///
/// ⚠️ **NOT IMPLEMENTED** — Maple Messenger is not yet implemented.
///
/// # TODO
///
/// - Implement messenger room creation/joining
/// - Handle member invitations
/// - Route messages to all messenger members
/// - Handle member leaving/disconnect
public struct MessengerHandler: PacketHandler {

    public typealias Packet = MapleStory62.MessengerRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Maple Messenger — not yet implemented.
    }
}
