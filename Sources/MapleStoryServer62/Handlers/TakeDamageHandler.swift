//
//  TakeDamageHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct TakeDamageHandler: PacketHandler {

    public typealias Packet = MapleStory62.TakeDamageRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Player takes damage — HP update and death handling not yet implemented.
    }
}
