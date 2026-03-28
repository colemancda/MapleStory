//
//  DistributeAPHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct DistributeAPHandler: PacketHandler {

    public typealias Packet = MapleStory83.DistributeAPRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else { return }
        guard character.ap > 0 else { return }

        var changedStats: MapleStat = .availableAP
        character.ap -= 1

        switch packet.stat {
        case 64:   // STR
            character.str = min(character.str + 1, 999)
            changedStats.formUnion(.str)
        case 128:  // DEX
            character.dex = min(character.dex + 1, 999)
            changedStats.formUnion(.dex)
        case 256:  // INT
            character.int = min(character.int + 1, 999)
            changedStats.formUnion(.int)
        case 512:  // LUK
            character.luk = min(character.luk + 1, 999)
            changedStats.formUnion(.luk)
        case 2048: // HP
            let gain = hpGainForJob(character.job)
            let newMax = min(UInt32(character.maxHp) + UInt32(gain), 30000)
            character.maxHp = UInt16(newMax)
            character.hp = min(character.hp, character.maxHp)
            changedStats.formUnion([.maxHP, .hp])
        case 8192: // MP
            let gain = mpGainForJob(character.job)
            let newMax = min(UInt32(character.maxMp) + UInt32(gain), 30000)
            character.maxMp = UInt16(newMax)
            character.mp = min(character.mp, character.maxMp)
            changedStats.formUnion([.maxMP, .mp])
        default:
            return
        }

        try await connection.database.insert(character)

        let notification = UpdateStatsNotification(
            announce: true,
            stats: changedStats,
            skin: nil, face: nil, hair: nil, level: nil, job: nil,
            str: changedStats.contains(.str) ? character.str : nil,
            dex: changedStats.contains(.dex) ? character.dex : nil,
            int: changedStats.contains(.int) ? character.int : nil,
            luk: changedStats.contains(.luk) ? character.luk : nil,
            hp: changedStats.contains(.hp) ? character.hp : nil,
            maxHp: changedStats.contains(.maxHP) ? character.maxHp : nil,
            mp: changedStats.contains(.mp) ? character.mp : nil,
            maxMp: changedStats.contains(.maxMP) ? character.maxMp : nil,
            ap: character.ap,
            sp: nil, exp: nil, fame: nil, meso: nil
        )
        try await connection.send(notification)
    }

    private func hpGainForJob(_ job: Job) -> UInt16 {
        switch job.type {
        case .warrior:  return UInt16.random(in: 20...24)
        case .magician: return UInt16.random(in: 6...10)
        case .bowman:   return UInt16.random(in: 16...20)
        case .thief:    return UInt16.random(in: 16...20)
        case .pirate:   return UInt16.random(in: 18...22)
        default:        return UInt16.random(in: 8...12)
        }
    }

    private func mpGainForJob(_ job: Job) -> UInt16 {
        switch job.type {
        case .warrior:  return UInt16.random(in: 2...4)
        case .magician: return UInt16.random(in: 18...22)
        case .bowman:   return UInt16.random(in: 10...12)
        case .thief:    return UInt16.random(in: 10...12)
        case .pirate:   return UInt16.random(in: 14...16)
        default:        return UInt16.random(in: 6...8)
        }
    }
}
