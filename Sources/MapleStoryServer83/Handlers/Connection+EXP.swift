//
//  Connection+EXP.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

extension MapleStoryServer.Connection
where ClientOpcode == MapleStory83.ClientOpcode, ServerOpcode == MapleStory83.ServerOpcode {

    func gainExp(_ amount: UInt32) async throws {
        guard var character = try await self.character else { return }
        guard character.level < 200 else { return }

        var changedStats: MapleStat = .exp
        var totalExpGained = UInt64(character.exp.rawValue) + UInt64(amount)

        while character.level < 200 {
            let idx = Int(character.level) - 1
            let needed = Experience.advancements.indices.contains(idx)
                ? UInt64(Experience.advancements[idx].rawValue)
                : UInt64.max
            guard totalExpGained >= needed else { break }
            totalExpGained -= needed
            character.level += 1
            changedStats.formUnion([.level, .availableAP])

            character.ap = min(character.ap + 5, 999)

            let spGain = spGranted(at: character.level, job: character.job)
            if spGain > 0 {
                character.sp = min(character.sp + UInt16(spGain), 999)
                changedStats.formUnion(.availableSP)
            }

            let (hpGain, mpGain) = levelUpHpMp(job: character.job)
            character.maxHp = UInt16(min(UInt32(character.maxHp) + UInt32(hpGain), 30000))
            character.maxMp = UInt16(min(UInt32(character.maxMp) + UInt32(mpGain), 30000))
            character.hp = min(character.hp, character.maxHp)
            character.mp = min(character.mp, character.maxMp)
            changedStats.formUnion([.maxHP, .maxMP, .hp, .mp])
        }

        character.exp = Experience(rawValue: UInt32(min(totalExpGained, UInt64(UInt32.max))))
        try await database.insert(character)

        let notification = MapleStory83.UpdateStatsNotification(
            announce: true,
            stats: changedStats,
            skin: nil, face: nil, hair: nil,
            level: changedStats.contains(.level) ? UInt8(character.level) : nil,
            job: changedStats.contains(.job) ? character.job : nil,
            str: nil, dex: nil, int: nil, luk: nil,
            hp: changedStats.contains(.hp) ? character.hp : nil,
            maxHp: changedStats.contains(.maxHP) ? character.maxHp : nil,
            mp: changedStats.contains(.mp) ? character.mp : nil,
            maxMp: changedStats.contains(.maxMP) ? character.maxMp : nil,
            ap: changedStats.contains(.availableAP) ? character.ap : nil,
            sp: changedStats.contains(.availableSP) ? character.sp : nil,
            exp: character.exp.rawValue,
            fame: nil, meso: nil
        )
        try await send(notification)
    }

    // MARK: - Private

    private func levelUpHpMp(job: Job) -> (hp: UInt16, mp: UInt16) {
        switch job.type {
        case .warrior:  return (UInt16.random(in: 24...28), UInt16.random(in: 4...6))
        case .magician: return (UInt16.random(in: 10...14), UInt16.random(in: 22...24))
        case .bowman:   return (UInt16.random(in: 20...24), UInt16.random(in: 14...16))
        case .thief:    return (UInt16.random(in: 20...24), UInt16.random(in: 14...16))
        case .pirate:   return (UInt16.random(in: 22...28), UInt16.random(in: 18...23))
        default:        return (UInt16.random(in: 12...16), UInt16.random(in: 10...12))
        }
    }

    private func spGranted(at level: UInt16, job: Job) -> Int {
        switch level {
        case 10: return job == .beginner ? 1 : 0
        case 30: return 3
        case 70: return 3
        case 120: return 3
        default: return 1
        }
    }
}
