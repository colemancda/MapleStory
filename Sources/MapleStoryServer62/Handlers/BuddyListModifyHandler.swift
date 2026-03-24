//
//  BuddyListModifyHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct BuddyListModifyHandler: PacketHandler {

    public typealias Packet = MapleStory62.BuddyListModifyRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Buddy list add / accept / remove — not yet implemented.
    }
}
