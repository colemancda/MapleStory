//
//  SpouseChatHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles spouse (couple) chat between married players.
///
/// Married players can use spouse chat to send private messages
/// to their partner. This works across different maps and channels.
///
/// # Spouse Chat Flow
///
/// 1. Player types message with spouse chat prefix
/// 2. Client sends spouse chat request
/// 3. Server verifies player is married
/// 4. Server looks up spouse character
/// 5. Server routes message to spouse's connection
/// 6. Spouse receives message in couple chat channel
///
/// # Requirements
///
/// - Both players must be married (to each other)
/// - Spouse must be online to receive message
/// - Works cross-channel within the same world
///
/// # Error Messages
///
/// - "You are not married" if player has no spouse
/// - "Your spouse is currently offline" if spouse not connected
public struct SpouseChatHandler: PacketHandler {

    public typealias Packet = MapleStory62.SpouseChatRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        let offlineMessage = "You are not married or your spouse is currently offline."

        guard character.isMarried else {
            try await connection.send(ServerMessageNotification.lightBlueText(message: offlineMessage))
            return
        }
        guard let recipientName = CharacterName(rawValue: packet.recipient) else {
            try await connection.send(ServerMessageNotification.lightBlueText(message: offlineMessage))
            return
        }

        let predicates: [Character.Predicate] = [
            .name(recipientName),
            .world(character.world)
        ]
        let predicate = FetchRequest.Predicate.compound(.and(predicates.map { .init(predicate: $0) }))
        guard let recipient = try await connection.database.fetch(
            Character.self,
            predicate: predicate,
            fetchLimit: 1
        ).first,
        recipient.isMarried else {
            try await connection.send(ServerMessageNotification.lightBlueText(message: offlineMessage))
            return
        }

        let spousePacket = SpousechatNotification(
            sender: character.name.rawValue,
            message: packet.message
        )
        do {
            try await connection.send(spousePacket, toCharacter: recipient.id)
            try await connection.send(spousePacket) // echo back to sender
        } catch {
            try await connection.send(ServerMessageNotification.lightBlueText(message: offlineMessage))
        }
    }
}
