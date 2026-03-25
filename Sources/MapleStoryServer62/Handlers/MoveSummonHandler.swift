//
//  MoveSummonHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles summon movement synchronization across players in a map.
///
/// When a player's summon (e.g., Bahamut, Silver Hawk) moves, the client
/// sends this packet so the server can broadcast movement to other players.
///
/// # Implementation Status
///
/// ⚠️ **NOT IMPLEMENTED** — Summon movement broadcasting is not yet implemented.
///
/// # TODO
///
/// - Look up summon in SummonRegistry
/// - Update summon position
/// - Broadcast movement to all players on the map
public struct MoveSummonHandler: PacketHandler {

    public typealias Packet = MapleStory62.MoveSummonRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Summon movement broadcast — not yet implemented.
    }
}
