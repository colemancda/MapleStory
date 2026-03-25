//
//  AutoAggroHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles auto-aggro (automatic aggression) monster requests.
///
/// # Auto-Aggro System
///
/// Some monsters automatically target and attack players when they get within
/// a certain range. This client request is sent when a monster has automatically
/// targeted the player.
///
/// # Aggro Flow
///
/// 1. Server-controlled monster detects nearby player
/// 2. Monster enters aggro state (targets player)
/// 3. Client receives monster control packet
/// 4. Client sends auto-aggro acknowledgment request
/// 5. Server acknowledges to keep monster control state synchronized
///
/// # Purpose
///
/// This handler acknowledges the auto-aggro ping from the client, ensuring the
/// monster control state stays synchronized between server and client.
///
/// # Validation
///
/// - Validates character is logged in
/// - Validates monster exists and is on the same map
/// - Ignores requests for invalid or out-of-range monsters
///
/// # Response
///
/// Sends MoveMonsterResponse packet with:
/// - Monster object ID
/// - Move ID = 0
/// - No skill usage (useSkill = false)
public struct AutoAggroHandler: PacketHandler {

    public typealias Packet = MapleStory62.AutoAggroRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        guard let instance = await MapMobRegistry.shared.instance(objectID: packet.objectID),
              instance.mapID == character.currentMap else { return }

        // Ack the aggro ping so the client keeps monster control state in sync.
        try await connection.send(MoveMonsterResponse(
            objectID: packet.objectID,
            moveID: 0,
            useSkill: false,
            mp: 0,
            skillID: 0,
            skillLevel: 0
        ))
    }
}
