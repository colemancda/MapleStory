//
//  DueyActionHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct DueyActionHandler: PacketHandler {

    public typealias Packet = MapleStory62.DueyActionRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Duey (delivery service) action — not yet implemented.
    }
}
