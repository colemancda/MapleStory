//
//  UseReturnScrollHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct UseReturnScrollHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseReturnScrollRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Use return scroll to warp to town — not yet implemented.
    }
}
