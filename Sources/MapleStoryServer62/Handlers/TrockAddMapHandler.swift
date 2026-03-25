//
//  TrockAddMapHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles adding maps to the Teleport Rock (Tock) favorites list.
///
/// Teleport Rocks are cash items that allow instant teleportation to
/// saved map locations. Players can save up to 5 map locations as
/// "favorites" for quick teleportation.
///
/// # Teleport Rock Features
///
/// - Save up to 5 favorite maps
/// - Teleport to any saved map instantly
/// - Works across different continents
/// - Cannot teleport to restricted maps
///
/// # Flow
///
/// 1. Player opens Teleport Rock UI
/// 2. Player clicks "Add Location"
/// 3. Current map is saved to favorites list
/// 4. Client sends add map request
/// 5. Server validates map can be saved
/// 6. Server saves map to player's favorites
///
/// # Implementation Status
///
/// ⚠️ **NOT IMPLEMENTED** — Teleport Rock map saving is not yet implemented.
public struct TrockAddMapHandler: PacketHandler {

    public typealias Packet = MapleStory62.TrockAddMapRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Add or remove a teleport rock map — not yet implemented.
    }
}
