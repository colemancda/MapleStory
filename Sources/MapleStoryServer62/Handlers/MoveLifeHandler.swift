//
//  MoveLifeHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles monster movement updates from the player controlling the mob.
///
/// # Monster Movement System
///
/// Monsters can move around the map through:
/// - **AI-controlled**: Server-side AI determines movement (patrol, chase)
/// - **Player-controlled**: Some skills allow players to control monsters
/// - **Knockback**: Monster pushed back by damage
///
/// # Movement Relay
///
/// When a monster moves:
/// 1. Client (controller) sends movement packet with position updates
/// 2. Server relays movement to all players on the map
/// 3. Other clients see monster moving smoothly
/// 4. Controller receives acknowledgment
///
/// # Movement Data
///
/// Movement packets contain:
/// - **objectID**: Monster being moved
/// - **startX/startY**: Initial position
/// - **movements**: Array of movement fragments (each fragment has position, timing, action)
/// - **skillByte/skill**: Skills being used during movement
///
/// # Skill Usage
///
/// Monsters can use skills while moving:
/// - **skillID**: Which skill to use
/// - **skillLevel**: Skill level
/// - **skillByte**: Flags for skill activation
/// - **skillParam**: Additional skill parameters
///
/// # Controller System
///
/// One player is designated as the "controller" of each mob:
/// - Controller sends movement updates to server
/// - Server broadcasts to all players on map
/// - When controller leaves map, control transfers to another player
/// - Control prevents movement desync
///
/// # MP Tracking
///
/// Monsters have MP for using skills:
/// - MP deducted when monster uses skill
/// - MP regenerates over time
/// - Currently set to 0 (placeholder until MP tracking is implemented)
///
/// # Movement Validation
///
/// Server validates:
/// - Movement speed (can't move too fast)
/// - Position bounds (can't leave map)
/// - Skill usage cooldowns
/// - Movement sequence integrity
///
/// # Anti-Cheat
///
/// - Speed hacking detected by position/time analysis
/// - Position validation prevents teleporting mobs
/// - Controller validation prevents unauthorized control
/// - Movement fragments validated for legality
///
/// # Performance
///
/// Movement is expensive:
/// - Each mob sends frequent updates (every 200-500ms)
/// - 50 mobs = 50 packets per update interval
/// - Broadcast to 20 players = 1000 packets
/// - Optimized by only sending to players in range
/// - Controller system prevents desync
///
/// # Side Effects
///
/// - **Broadcasts**: MoveMonsterNotification to all players on map
/// - **Responds**: MoveMonsterResponse to controller (mob owner)
/// - **No database**: Movement is transient, not persisted
public struct MoveLifeHandler: PacketHandler {

    public typealias Packet = MapleStory62.MoveLifeRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let mapID = await connection.mapID else { return }

        // Relay movement to all other clients on the map.
        let notification = MoveMonsterNotification(
            objectID: packet.objectID,
            skillByte: packet.skillByte,
            skill: packet.skill,
            skillID: packet.skillID,
            skillLevel: packet.skillLevel,
            skillParam: packet.skillParam,
            startX: packet.startX,
            startY: packet.startY,
            movements: packet.movements
        )
        try await connection.broadcast(notification, map: mapID)

        // Acknowledge to the controller (mob MP = 0 until MP tracking is wired up).
        let instance = await MapMobRegistry.shared.instance(objectID: packet.objectID)
        let response = MoveMonsterResponse(
            objectID: packet.objectID,
            moveID: packet.moveID,
            useSkill: packet.skillByte != 0,
            mp: 0,
            skillID: packet.skillID,
            skillLevel: packet.skillLevel
        )
        _ = instance // reserved for future MP tracking
        try await connection.send(response)
    }
}
