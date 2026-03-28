//
//  GeneralChatHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct GeneralChatHandler: PacketHandler {

    public typealias Packet = MapleStory83.GeneralChatRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        let notification = ChatTextNotification(
            characterID: character.index,
            isGM: false,
            message: packet.message,
            show: packet.show ? 1 : 0
        )
        try await connection.broadcast(notification, map: character.currentMap)
    }
}
