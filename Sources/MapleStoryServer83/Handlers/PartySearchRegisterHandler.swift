//
//  PartySearchRegisterHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct PartySearchRegisterHandler: PacketHandler {

    public typealias Packet = MapleStory83.PartySearchRegisterRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Register for party search — not yet implemented.
    }
}
