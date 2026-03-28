//
//  PetLootHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct PetLootHandler: PacketHandler {

    public typealias Packet = MapleStory83.PetLootRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Pet auto-loot pickup — not yet implemented.
    }
}
