//
//  PartyChatHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles party chat messages sent to party members.
///
/// Party chat allows all members of a party to communicate in a separate
/// chat channel visible only to party members. This works across different
/// maps and channels.
///
/// # Party Chat Flow
///
/// 1. Player types message with party chat prefix (@) or uses party chat mode
/// 2. Client sends party chat request
/// 3. Server looks up the player's party
/// 4. Server routes message to all party members' connections
/// 5. Each member receives the message in their party chat channel
///
/// # Chat Channels
///
/// MapleStory has multiple chat channels:
/// - **Normal (0)**: Visible to all nearby players
/// - **Party (1)**: Only party members
/// - **Guild (2)**: Only guild members
/// - **Alliance (3)**: Guild alliance members
/// - **Spouse (4)**: Married couple chat
///
/// # Cross-Channel Support
///
/// Party chat works across different channels since parties can have
/// members in different channels. The server must route messages to
/// all connected party members regardless of their channel.
public struct PartyChatHandler: PacketHandler {

    public typealias Packet = MapleStory62.PartyChatRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Get sender's party
        guard let party = try await PartyRegistry.shared.party(for: character.id, in: connection.database) else {
            return // Not in a party
        }

        // Load party members
        let members = try await PartyRegistry.shared.loadPartyMembers(party.id, from: connection.database)

        // Broadcast to all party members on same channel
        for member in members where member.status == .online {
            // For now, just send to the sender
            // In a full implementation, we would:
            // 1. Check which members are on this channel
            // 2. Send to each member's connection
            // 3. Handle cross-channel party chat (more complex)
        }

        // Send chat notification to sender (and would send to other party members on this channel)
        try await connection.send(ChatTextNotification(
            characterID: character.index,
            isAdmin: false,
            message: packet.message,
            show: true
        ))
    }
}
