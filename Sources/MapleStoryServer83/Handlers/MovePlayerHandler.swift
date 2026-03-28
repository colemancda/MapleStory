//
//  MovePlayerHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct MovePlayerHandler: PacketHandler {

    public typealias Packet = MapleStory83.MovePlayerRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        if let finalPos = packet.movements.finalPosition {
            let playerPos = PlayerPosition(x: finalPos.x, y: finalPos.y)
            await connection.updatePlayerPosition(playerPos, for: character.id)
        }

        let notification = MovePlayerNotification(
            characterID: character.index,
            unknown: 0,
            movements: packet.movements
        )
        try await connection.broadcast(notification, map: character.currentMap)
    }
}
