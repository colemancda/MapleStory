//
//  MonsterCarnivalHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct MonsterCarnivalHandler: PacketHandler {

    public typealias Packet = MapleStory83.MonsterCarnivalRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Monster Carnival — not yet implemented.
    }
}
