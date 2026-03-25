//
//  SummonAttackHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles summon attack packets (damage from summoned creatures).
///
/// Some classes (e.g., Bishop with Bahamut, Ranger with Silver Hawk)
/// can summon creatures that automatically attack nearby monsters.
/// This handler processes the damage dealt by those summons.
///
/// # Summon Types
///
/// - **Bahamut**: Bishop's dragon summon (holy damage)
/// - **Silver Hawk**: Ranger's bird summon
/// - **Golden Eagle**: Sniper's bird summon
/// - **Puppet**: Ranger/Sniper decoy summon
/// - **Gaviota**: Outlaw's bird summon
///
/// # Attack Flow
///
/// 1. Summon automatically targets nearby monsters
/// 2. Summon attacks and deals damage
/// 3. Client sends summon attack packet
/// 4. Server validates summon belongs to player
/// 5. Server applies damage to target monster
/// 6. Server broadcasts attack animation to map players
///
/// # Implementation Status
///
/// ⚠️ **NOT IMPLEMENTED** — Summon attack damage is not yet implemented.
public struct SummonAttackHandler: PacketHandler {

    public typealias Packet = MapleStory62.SummonAttackRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        // Broadcast summon attack to other players on the same map
        guard let mapID = await connection.mapID else { return }

        try await connection.broadcast(SummonAttackNotification(
            characterID: character.index,
            objectID: packet.objectID,
            numAttacked: packet.numAttacked
        ), map: mapID)

        // TODO: Implement damage calculation
        // In a full implementation, we would:
        // 1. Calculate damage based on summon skill and character stats
        // 2. Apply damage to the attacked monsters
        // 3. Handle monster death and experience gain
    }
}
