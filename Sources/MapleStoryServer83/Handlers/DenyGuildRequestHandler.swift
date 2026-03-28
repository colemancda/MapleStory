//
//  DenyGuildRequestHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct DenyGuildRequestHandler: PacketHandler {

    public typealias Packet = MapleStory83.DenyGuildRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Deny guild invitation — not yet implemented.
    }
}
