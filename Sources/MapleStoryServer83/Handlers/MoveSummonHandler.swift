//
//  MoveSummonHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct MoveSummonHandler: PacketHandler {

    public typealias Packet = MapleStory83.MoveSummonRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        guard let mapID = await connection.mapID else { return }

        try await connection.broadcast(
            MoveSummonNotification(
                characterID: character.index,
                summonObjectID: packet.objectID,
                startX: packet.startX,
                startY: packet.startY,
                movements: []
            ),
            map: mapID
        )
    }
}
