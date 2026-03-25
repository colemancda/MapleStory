//
//  CancelDebuffHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct CancelDebuffHandler: PacketHandler {

    public typealias Packet = MapleStory62.CancelDebuffRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        _ = packet
        guard let character = try await connection.character else { return }

        // Debuff state is not tracked separately yet; at minimum keep buff registry clean.
        await CharacterBuffRegistry.shared.cleanupExpired(for: character.id)
    }
}
