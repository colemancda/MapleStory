//
//  PlayerLoginHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation
import CoreModel
import MapleStory28
import MapleStoryServer

public struct PlayerLoginHandler: PacketHandler {
    
    public let world: World.ID
    
    public init(world: World.ID) {
        self.world = world
    }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet request: MapleStory28.PlayerLoginRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let values = try await connection.playerLogin(
            character: request.character,
            world: world
        )
        //try await connection.send(response)
    }
}
