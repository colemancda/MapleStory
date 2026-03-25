//
//  PartySearchStartHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles initiating a search for parties to join.
///
/// Players looking for a party can search the party listing to find
/// parties that match their level and preferences.
///
/// # Search Criteria
///
/// - **Level range**: Only show parties appropriate for player's level
/// - **Map/area**: Find parties in specific areas
/// - **Class**: Some parties prefer certain classes
///
/// # Implementation Status
///
/// ⚠️ **NOT IMPLEMENTED** — Party search functionality is not yet implemented.
public struct PartySearchStartHandler: PacketHandler {

    public typealias Packet = MapleStory62.PartySearchStartRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Start party search — not yet implemented.
    }
}
