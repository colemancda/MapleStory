//
//  PartySearchUpdateHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct PartySearchUpdateHandler: PacketHandler {

    public typealias Packet = MapleStory83.PartySearchUpdateRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Party search update — not yet implemented.
    }
}
