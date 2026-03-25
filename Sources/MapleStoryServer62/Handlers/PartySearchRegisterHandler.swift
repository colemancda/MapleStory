//
//  PartySearchRegisterHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles party search registration (listing party as seeking members).
///
/// The party search system allows parties to advertise they are looking
/// for members, and solo players to find parties to join.
///
/// # Registration Flow
///
/// 1. Party leader opens party search UI
/// 2. Leader fills in search criteria (min/max level, class preferences, etc.)
/// 3. Client sends register request
/// 4. Server adds party to the searchable listings
/// 5. Other players can see and request to join
///
/// # Implementation Status
///
/// ⚠️ **NOT IMPLEMENTED** — Party search registration is not yet implemented.
public struct PartySearchRegisterHandler: PacketHandler {

    public typealias Packet = MapleStory62.PartySearchRegisterRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Register for party search — not yet implemented.
    }
}
