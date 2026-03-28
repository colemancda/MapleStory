//
//  MoveSummonHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct MoveSummonHandler: PacketHandler {

    public typealias Packet = MapleStory83.MoveSummonRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Summon movement broadcast — not yet implemented.
    }
}
