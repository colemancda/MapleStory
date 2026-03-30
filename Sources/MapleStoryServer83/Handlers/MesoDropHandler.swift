//
//  MesoDropHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct MesoDropHandler: PacketHandler {

    public typealias Packet = MapleStory83.MesoDropRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        guard character.meso >= packet.amount else { return }

        var updatedCharacter = character
        updatedCharacter.meso -= packet.amount
        try await connection.database.insert(updatedCharacter)

        guard let mapID = await connection.mapID else { return }

        let objectID = UInt32.random(in: 1...1_000_000)

        try await connection.broadcast(DropItemFromMapObjectNotification(
            mod: 0,
            objectID: objectID,
            isMeso: true,
            itemID: packet.amount,
            ownerID: character.index,
            dropType: 0,
            x: 0,
            y: 0,
            dropperObjectID: character.index
        ), map: mapID)
    }
}
