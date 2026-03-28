//
//  RingActionHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct RingActionHandler: PacketHandler {

    public typealias Packet = MapleStory83.RingActionRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Wedding ring action — not yet implemented.
    }
}
