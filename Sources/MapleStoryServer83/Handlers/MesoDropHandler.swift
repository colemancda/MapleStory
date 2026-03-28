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
        let timestamp = UInt32(Date().timeIntervalSince1970 * 1000)

        try await connection.broadcast(DropItemFromMapobjectNotification(
            source: 1,
            objectID: objectID,
            itemID: 0,
            quantity: packet.amount,
            ownerID: character.index,
            ownerType: 1,
            x: 0,
            y: 0,
            timestamp: timestamp
        ), map: mapID)
    }
}
