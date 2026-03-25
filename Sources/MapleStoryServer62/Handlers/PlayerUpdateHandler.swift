//
//  PlayerUpdateHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles client stat refresh requests.
///
/// The client periodically sends this packet to request a refresh of the
/// character's stats. This ensures the client display stays synchronized
/// with the server-side stat values, particularly after equipment changes,
/// buff applications, or other stat modifications.
///
/// # Use Cases
///
/// Client sends this when:
/// - Opening the character stat window
/// - After equipping/unequipping items
/// - After applying buffs
/// - After leveling up
/// - Periodically as a general sync mechanism
///
/// # Response
///
/// No response is currently sent. The client's own tracking should be
/// sufficient for display purposes. A full implementation might send
/// `UpdateStatsNotification` to push current stat values.
///
/// # TODO
///
/// - Send current character stats in response
/// - Ensure client display matches server state
public struct PlayerUpdateHandler: PacketHandler {

    public typealias Packet = MapleStory62.PlayerUpdateRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Client stat refresh request — no response required.
    }
}
