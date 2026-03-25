//
//  UseInnerPortalHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles inner portal usage (teleporting within the same map).
///
/// Inner portals are special teleport points within a map that
/// allow quick travel between different areas. Unlike regular doors,
/// inner portals don't require a door object ID - just client just
/// sends the target position directly.
///
/// # Inner Portal Types
///
/// - **Flash jumps**: Quick teleport to platform
/// - **Rope lifts**: Zip line travel
/// - **Teleporters**: Sci-fi teleport pads
///
/// # Flow
///
/// 1. Player steps on inner portal
/// 2. Client sends inner portal request with target position
/// 3. Server validates position is within the same map
/// 4. Server updates player position
/// 5. Server broadcasts position update to other players
///
/// # Implementation Status
///
/// ⚠️ **NOT IMPLEMENTED** — Inner portals are not yet implemented.
public struct UseInnerPortalHandler: PacketHandler {

    public typealias Packet = MapleStory62.UseInnerPortalRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        _ = packet
        guard let _ = try await connection.character else { return }

        // Inner portal pathing requires per-map scripted portal tables.
        try await connection.send(ServerMessageNotification.notice(
            message: "This inner portal is not available yet."
        ))
    }
}
