//
//  PetAutoPotHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct PetAutoPotHandler: PacketHandler {

    public typealias Packet = MapleStory62.PetAutoPotRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Pet auto-pot use — not yet implemented.
    }
}
