//
//  EnterMTSHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles requests to enter the Maple Trading System (MTS).
///
/// The MTS was a player-to-player marketplace where items could be listed
/// for sale using NX (real currency). Players could browse listings and
/// purchase items from other players.
///
/// # MTS History
///
/// The MTS was a feature in older versions of MapleStory (around version 62)
/// that allowed trading items for NX cash. It was later removed from the game
/// as it was controversial (real-money trading).
///
/// # Implementation Status
///
/// ⚠️ **NOT IMPLEMENTED** — MTS is not implemented in this server.
///
/// # TODO
///
/// - Implement MTS entry protocol if needed for v62 compatibility
/// - Create item listing system
/// - Handle NX transactions for MTS purchases
public struct EnterMTSHandler: PacketHandler {

    public typealias Packet = MapleStory62.EnterMTSRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Enter MTS (Maple Trading System) — not yet implemented.
    }
}
