//
//  SkillEffectHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles skill effect animation broadcasting to other players.
///
/// When a player uses a skill, the visual effect needs to be shown to
/// other players on the same map. This handler broadcasts the skill
/// effect animation so all players see the skill being used.
///
/// # Skill Effects
///
/// Different skills have different visual effects:
/// - **Attack skills**: Weapon swing with particle effects
/// - **Buff skills**: Character glow or aura
/// - **Heal skills**: Light particles around target
/// - **Summon skills**: Appearance animation for summoned creature
///
/// # Broadcasting
///
/// Sends `SkillEffectNotification` to all players on the current map with:
/// - **characterID**: The player using the skill
/// - **skillID**: Which skill is being used
/// - **level**: Skill level (affects animation intensity)
/// - **flags**: Additional effect flags
/// - **speed**: Animation playback speed
public struct SkillEffectHandler: PacketHandler {

    public typealias Packet = MapleStory62.SkillEffectRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Broadcast skill effect to other players on the same map
        guard let mapID = await connection.mapID else { return }

        try await connection.broadcast(SkillEffectNotification(
            characterID: character.index,
            skillID: packet.skillID,
            level: packet.level,
            flags: packet.flags,
            speed: packet.speed
        ), map: mapID)
    }
}
