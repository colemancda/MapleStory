//
//  MessengerHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct MessengerHandler: PacketHandler {

    public typealias Packet = MapleStory83.MessengerRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Maple Messenger — not yet implemented.
    }
}
