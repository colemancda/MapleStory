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

public struct PartyChatHandler: PacketHandler {

    public typealias Packet = MapleStory62.PartyChatRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Get sender's party
        guard let party = await PartyRegistry.shared.party(for: character.id) else {
            return // Not in a party
        }

        // Broadcast to all party members on same channel
        for member in party.members.values where member.status == .online {
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
