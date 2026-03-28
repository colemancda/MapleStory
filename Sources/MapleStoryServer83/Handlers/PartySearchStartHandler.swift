//
//  PartySearchStartHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct PartySearchStartHandler: PacketHandler {

    public typealias Packet = MapleStory83.PartySearchStartRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Start party search — not yet implemented.
    }
}
