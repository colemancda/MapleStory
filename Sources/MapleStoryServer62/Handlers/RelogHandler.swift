//
//  RelogHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles relog (return to character selection) requests.
///
/// When a player wants to switch characters without fully logging out,
/// they can use the relog feature to return to the character selection screen.
///
/// # Relog Flow
///
/// 1. Player uses the "Return to Character Select" option
/// 2. Client sends relog request
/// 3. Server sends `RelogResponse` to confirm
/// 4. Client disconnects from channel and returns to character selection
///
/// # State Cleanup
///
/// On relog, the server should clean up the player's in-game state:
/// - Remove from current map
/// - Remove from party (or keep party)
/// - Save character progress
/// - Release map spawn points
///
/// # Response
///
/// Sends `RelogResponse` which confirms the relog and instructs
/// the client to transition back to the character selection screen.
public struct RelogHandler: PacketHandler {

    public typealias Packet = MapleStory62.RelogRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        try await connection.send(RelogResponse())
    }
}
