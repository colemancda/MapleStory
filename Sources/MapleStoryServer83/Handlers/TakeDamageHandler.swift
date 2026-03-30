//
//  TakeDamageHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct TakeDamageHandler: PacketHandler {

    public typealias Packet = MapleStory83.TakeDamageRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        var damage = Int32(bitPattern: packet.damage)
        let monsterOID = packet.monsterOID
        let monsterIDFrom = packet.monsterIDFrom
        let damageFrom = packet.damageFrom
        let direction = packet.direction

        // Validate the attacker and check neutralise status.
        if damageFrom != -3 && damageFrom != -4 {
            if let mob = await connection.mobInstance(objectID: monsterOID) {
                // Attacker ID must match what the client reported.
                guard mob.mobID == monsterIDFrom else { return }
                // If the mob has NEUTRALISE status it cannot deal damage.
                if await connection.mobIsNeutralised(objectID: monsterOID) { return }
            }
        }

        // Cap damage using mob's physical attack stat if available.
        if packet.damageFrom >= 0, monsterIDFrom > 0 {
            if let mobTemplate = await connection.mobData(id: monsterIDFrom) {
                let cap = Int32(max(0, mobTemplate.paDamage))
                if cap > 0 { damage = min(damage, cap) }
            }
        }

        // Apply buff-based damage modifiers (stubs — full implementation requires buff stat lookup).
        // Magic Guard: converts a portion of HP damage to MP damage.
        // Mesoguard: halves damage, drains mesos.
        // Achilles / High Defense: reduce damage by a multiplier.
        // Combo Barrier: reduce damage by a multiplier.
        // Power Guard: reflect a portion of damage back at the mob.

        // Apply damage to character HP.
        if damage > 0 {
            let newHP = Int32(character.hp) - damage
            character.hp = newHP > 0 ? UInt16(newHP) : 0
            try await connection.database.insert(character)
            try await connection.send(UpdateStatsNotification.hp(character.hp))
        }

        // Broadcast to other players on the map.
        let mapID = character.currentMap
        let notification = DamagePlayerNotification(
            characterID: character.index,
            skill: damageFrom,
            unknown: damageFrom == -3 ? 0 : nil,
            damage: damage,
            monsterIDFrom: (damageFrom != -4) ? monsterIDFrom : nil,
            direction: (damageFrom != -4) ? direction : nil
        )
        try await connection.broadcast(notification, map: mapID)

        // Handle death.
        if character.hp == 0 {
            character.hp = max(1, character.maxHp / 10)
            try await connection.database.insert(character)
            try await connection.warp(to: character.currentMap, spawn: 0)
        }
    }
}
