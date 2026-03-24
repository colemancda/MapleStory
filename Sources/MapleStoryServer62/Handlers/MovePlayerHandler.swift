//
//  MovePlayerHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct MovePlayerHandler: PacketHandler {

    public typealias Packet = MapleStory62.MovePlayerRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Extract final position from movement data
        if let finalPos = packet.movements.finalPosition {
            // Update player position registry
            let playerPos = PlayerPosition(x: finalPos.x, y: finalPos.y)
            await PlayerPositionRegistry.shared.updatePosition(playerPos, for: character.id)
        }

        // Broadcast movement to other players on the map
        let notification = MovePlayerNotification(
            characterID: character.index,
            movements: packet.movements
        )
        try await connection.broadcast(notification, map: character.currentMap)
    }
}
