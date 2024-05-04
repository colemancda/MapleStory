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
    
    public let channel: Channel.ID
    
    public init(channel: Channel.ID) {
        self.channel = channel
    }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet request: MapleStory28.PlayerLoginRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let values = try await connection.playerLogin(
            character: request.character,
            channel: channel
        )
        let warpMapNotification = WarpToMapNotification(channel: values.channel, character: values.character)
        try await connection.send(warpMapNotification)
    }
}
