//
//  ChangeChannelHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct ChangeChannelHandler: PacketHandler {

    public typealias Packet = MapleStory62.ChangeChannelRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Channel migration — redirect client to target channel server not yet implemented.
    }
}
