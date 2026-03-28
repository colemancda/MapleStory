//
//  CancelDebuffHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct CancelDebuffHandler: PacketHandler {

    public typealias Packet = MapleStory83.CancelDebuffRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        _ = packet
        guard let character = try await connection.character else { return }
        await CharacterBuffRegistry.shared.cleanupExpired(for: character.id)
    }
}
