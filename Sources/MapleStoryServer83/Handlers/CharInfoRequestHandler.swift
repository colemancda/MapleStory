//
//  CharInfoRequestHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct CharInfoRequestHandler: PacketHandler {

    public typealias Packet = MapleStory83.CharInfoRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // characterID in the packet is the target's map object ID (Character.Index).
        // Fetch the target character by their numeric index within the same world.
        let predicates: [Character.Predicate] = [
            .index(packet.characterID),
            .world(character.world)
        ]
        let predicate = FetchRequest.Predicate.compound(.and(predicates.map { .init(predicate: $0) }))
        guard let target = try await connection.database.fetch(
            Character.self,
            predicate: predicate,
            fetchLimit: 1
        ).first else { return }

        // Don't send self-info.
        guard target.id != character.id else { return }

        // TODO: send proper charInfo packet (opcode 0x3D) once CharInfoResponse is implemented.
    }
}
