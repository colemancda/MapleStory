//
//  MTSOperationHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles Maple Trading System (MTS) buy/sell/search operations.
///
/// The MTS was a real-money player-to-player trading system in older MapleStory versions.
/// Players could list items for sale using NX currency.
///
/// # Implementation Status
///
/// ⚠️ **NOT IMPLEMENTED** — MTS operations are not implemented in this server.
public struct MTSOperationHandler: PacketHandler {

    public typealias Packet = MapleStory62.MTSOperationRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // MTS buy / sell / search operation — not yet implemented.
    }
}
