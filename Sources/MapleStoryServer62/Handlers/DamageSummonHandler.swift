//
//  DamageSummonHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles damage taken by player summons.
///
/// When a player has an active summon (e.g., Bahamut for Bishop, Silver Hawk
/// for Ranger), monsters can attack and damage the summon. This packet is sent
/// by the client to report damage taken by the summon.
///
/// # Summon System
///
/// Summons are temporary creatures summoned by certain skills:
/// - **Bahamut** (Bishop): Holy dragon that attacks nearby enemies
/// - **Silver Hawk** (Ranger): Bird that attacks nearby enemies
/// - **Ifrit/Elquines** (Ice/Lightning Mage): Elemental summons
/// - **Beholder** (Dark Knight): Passive buff/heal summon
///
/// Each summon has HP and can be killed by monsters.
///
/// # Implementation Status
///
/// ⚠️ **NOT IMPLEMENTED** — Summon damage tracking is not yet implemented.
///
/// # TODO
///
/// - Track summon HP in SummonRegistry
/// - Handle summon death (remove from map)
/// - Broadcast summon HP changes to map
/// - Notify owner when summon dies
public struct DamageSummonHandler: PacketHandler {

    public typealias Packet = MapleStory62.DamageSummonRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else {
            return
        }

        // Broadcast summon damage to other players on the map
        // TODO: Implement proper map-based broadcasting when PlayerPositionRegistry is available
        print("[Summon] Character \(character.index)'s summon took \(packet.damage) damage from monster \(packet.monsterIDFrom)")

        // In a full implementation, we would:
        // - Track summon HP in SummonRegistry
        // - Handle summon death (remove from map if HP <= 0)
        // - Broadcast summon HP changes to map
        // - Notify owner when summon dies
    }
}