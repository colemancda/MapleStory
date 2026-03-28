//
//  DamageReactorHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct DamageReactorHandler: PacketHandler {

    public typealias Packet = MapleStory83.DamageReactorRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Reactor hit — state change and reward drop not yet implemented.
    }
}
