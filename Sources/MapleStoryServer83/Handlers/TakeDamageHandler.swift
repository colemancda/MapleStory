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

        let damage: UInt32
        if packet.damageFrom >= 0, packet.monsterIDFrom > 0 {
            if let mob = await connection.mobData(id: packet.monsterIDFrom) {
                let cap = UInt32(max(0, mob.paDamage))
                damage = (cap > 0) ? min(packet.damage, cap) : packet.damage
            } else {
                damage = packet.damage
            }
        } else {
            damage = packet.damage
        }

        let newHP = UInt32(character.hp) > damage ? UInt16(UInt32(character.hp) - damage) : 0
        character.hp = newHP
        try await connection.database.insert(character)

        try await connection.send(UpdateStatsNotification.hp(newHP))

        if newHP == 0 {
            character.hp = max(1, character.maxHp / 10)
            try await connection.database.insert(character)
            try await connection.warp(to: character.currentMap, spawn: 0)
        }
    }
}
