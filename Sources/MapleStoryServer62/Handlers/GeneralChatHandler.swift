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
        // Broadcast chat message to other players on the same map — not yet implemented.
    }
}
