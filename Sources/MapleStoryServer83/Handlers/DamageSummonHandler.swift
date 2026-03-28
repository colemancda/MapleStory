//
//  DamageSummonHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct DamageSummonHandler: PacketHandler {

    public typealias Packet = MapleStory83.DamageSummonRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Summon damage tracking — not yet implemented.
    }
}
