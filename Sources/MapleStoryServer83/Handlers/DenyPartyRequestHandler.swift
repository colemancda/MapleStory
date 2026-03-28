//
//  DenyPartyRequestHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct DenyPartyRequestHandler: PacketHandler {

    public typealias Packet = MapleStory83.DenyPartyRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Deny party invitation — rejection notification not yet implemented.
    }
}
