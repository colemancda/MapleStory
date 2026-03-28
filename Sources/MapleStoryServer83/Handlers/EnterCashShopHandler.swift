//
//  EnterCashShopHandler.swift
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct EnterCashShopHandler: PacketHandler {

    public typealias Packet = MapleStory83.EnterCashShopRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Enter Cash Shop — not yet implemented.
    }
}
