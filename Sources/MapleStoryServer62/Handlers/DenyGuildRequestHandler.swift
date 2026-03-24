//
//  DenyGuildRequestHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct DenyGuildRequestHandler: PacketHandler {

    public typealias Packet = MapleStory62.DenyGuildRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Deny guild invitation — not yet implemented.
    }
}
