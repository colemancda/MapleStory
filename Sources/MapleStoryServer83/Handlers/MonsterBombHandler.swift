//
//  MonsterBombHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct MonsterBombHandler: PacketHandler {

    public typealias Packet = MapleStory83.MonsterBombRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Monster self-destruct bomb — not yet implemented.
    }
}
