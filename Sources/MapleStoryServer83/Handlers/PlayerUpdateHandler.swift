//
//  PlayerUpdateHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct PlayerUpdateHandler: PacketHandler {

    public typealias Packet = MapleStory83.PlayerUpdateRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Client stat refresh request — no response required.
    }
}
