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
