//
//  UseChairHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct UseChairHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseChairRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Validate chair item ID (starts with 301)
        guard packet.itemID / 1000 == 301 else {
            return // Not a chair item
        }

        // Send chair notification to spawn the chair on client
        try await connection.send(ShowChairNotification(
            characterID: character.index,
            itemID: packet.itemID
        ))

        // TODO: Start HP/MP regeneration timer while sitting
        // In a full implementation, we would:
        // 1. Store which chair the character is using
        // 2. Start a timer to periodically restore HP/MP
        // 3. Stop regeneration when character stands up
    }
}

// MARK: - Show Chair Notification

/// Sent when a character sits in a chair
public struct ShowChairNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showChair }

    /// Character ID sitting in the chair
    public let characterID: UInt32

    /// Chair item ID
    public let itemID: UInt32

    public init(characterID: UInt32, itemID: UInt32) {
        self.characterID = characterID
        self.itemID = itemID
    }
}

