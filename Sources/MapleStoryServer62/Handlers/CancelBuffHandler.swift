//
//  CancelBuffHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct CancelBuffHandler: PacketHandler {

    public typealias Packet = MapleStory62.CancelBuffRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else {
            return
        }

        // Remove the buff from the registry
        let removed = await CharacterBuffRegistry.shared.removeBuff(
            skillID: packet.skillID,
            from: character.id
        )

        guard removed else {
            return // Buff wasn't active
        }

        // Send buff cancellation notification to client
        try await connection.send(CancelBuffNotification(skillID: packet.skillID))

        // TODO: Recalculate character stats without buff
        // TODO: Save character (if stats were modified)
    }
}
