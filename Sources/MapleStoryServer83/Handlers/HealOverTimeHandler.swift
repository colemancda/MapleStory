//
//  HealOverTimeHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct HealOverTimeHandler: PacketHandler {

    public typealias Packet = MapleStory83.HealOverTimeRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }

        let healHP = min(packet.hp, 140)
        let healMP = packet.mp

        var changedStats: MapleStat = []

        if healHP > 0, character.hp < character.maxHp {
            let newHp = min(UInt32(character.hp) + UInt32(healHP), UInt32(character.maxHp))
            character.hp = UInt16(newHp)
            changedStats.formUnion(.hp)
        }

        if healMP > 0, character.mp < character.maxMp {
            let newMp = min(UInt32(character.mp) + UInt32(healMP), UInt32(character.maxMp))
            character.mp = UInt16(newMp)
            changedStats.formUnion(.mp)
        }

        guard !changedStats.isEmpty else { return }

        try await connection.database.insert(character)

        let notification = UpdateStatsNotification(
            announce: false,
            stats: changedStats,
            skin: nil, face: nil, hair: nil, level: nil, job: nil,
            str: nil, dex: nil, int: nil, luk: nil,
            hp: changedStats.contains(.hp) ? character.hp : nil,
            maxHp: nil,
            mp: changedStats.contains(.mp) ? character.mp : nil,
            maxMp: nil,
            ap: nil, sp: nil, exp: nil, fame: nil, meso: nil
        )
        try await connection.send(notification)
    }
}
