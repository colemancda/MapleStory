//
//  GeneralChatHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct GeneralChatHandler: PacketHandler {

    public typealias Packet = MapleStory62.GeneralChatRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        let notification = ChatTextNotification(
            characterID: character.index,
            message: packet.message,
            show: packet.show
        )
        try await connection.broadcast(notification, map: character.currentMap)
    }
}
