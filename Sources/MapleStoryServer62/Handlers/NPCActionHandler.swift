//
//  NPCActionHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles NPC action/movement packets during NPC conversations.
///
/// While a player is in a conversation with an NPC, the NPC may perform
/// movement or animation actions. This packet handles those NPC-side actions
/// during the conversation flow.
///
/// # NPC Conversation Flow
///
/// 1. Player clicks NPC → NPCTalkHandler starts conversation
/// 2. NPC sends dialog → player responds
/// 3. NPCTalkMoreHandler handles player responses
/// 4. NPCActionHandler handles NPC animations/movements during conversation
/// 5. Conversation ends when player clicks OK/Cancel or exhausts dialog
///
/// # Implementation
///
/// This handler echoes the NPC action back to the client, allowing
/// the client to display the NPC animation/movement during conversation.
public struct NPCActionHandler: PacketHandler {

    public typealias Packet = MapleStory62.NPCActionRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Echo NPC action back to client
        // This allows the client to display NPC animations/movements during conversations
        switch packet {
        case .talk(let value0, let value1):
            try await connection.send(NPCActionNotification.talk(value0, value1))
        case .move(let data):
            try await connection.send(NPCActionNotification.move(data))
        }
    }
}

// MARK: - NPC Action Notification

public enum NPCActionNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .npcAction }

    /// Talk action
    case talk(UInt32, UInt16)

    /// Move action
    case move(Data)
}

extension NPCActionNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case .talk(let value0, let value1):
            try container.encode(value0)
            try container.encode(value1)
        case .move(let data):
            try container.encode(data)
        }
    }
}
