//
//  Connection+EXP.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

extension MapleStoryServer.Connection
where ClientOpcode == MapleStory62.ClientOpcode, ServerOpcode == MapleStory62.ServerOpcode {

    /// Grant experience to the logged-in character, levelling up as many times as needed.
    /// Saves the updated character to the DB and sends `UpdateStatsNotification` to the client.
    func gainExp(_ amount: UInt32) async throws {
        guard var character = try await self.character else { return }
        guard character.level < 200 else { return }

        // Add exp, accumulate changed stats for notification.
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

            // AP and SP granted on level-up.
            character.ap = min(character.ap + 5, 999)

            // SP granted at job-advancement levels.
            let spGain = spGranted(at: character.level, job: character.job)
            if spGain > 0 {
                character.sp = min(character.sp + UInt16(spGain), 999)
                changedStats.formUnion(.availableSP)
            }

            // Increase maxHP and maxMP on level-up by a job-based amount.
            let (hpGain, mpGain) = levelUpHpMp(job: character.job)
            let newMaxHp = min(UInt32(character.maxHp) + UInt32(hpGain), 30000)
            let newMaxMp = min(UInt32(character.maxMp) + UInt32(mpGain), 30000)
            character.maxHp = UInt16(newMaxHp)
            character.maxMp = UInt16(newMaxMp)
            character.hp = min(character.hp, character.maxHp)
            character.mp = min(character.mp, character.maxMp)
            changedStats.formUnion([.maxHP, .maxMP, .hp, .mp])
        }

        character.exp = Experience(rawValue: UInt32(min(totalExpGained, UInt64(UInt32.max))))
        try await database.insert(character)

        let notification = UpdateStatsNotification(
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

    // MARK: - Helpers

    /// HP and MP gained on level-up, by job class.
    private func levelUpHpMp(job: Job) -> (hp: UInt16, mp: UInt16) {
        let hp: UInt16
        let mp: UInt16
        switch job.type {
        case .warrior:
            hp = UInt16.random(in: 24...28)
            mp = UInt16.random(in: 4...6)
        case .magician:
            hp = UInt16.random(in: 10...14)
            mp = UInt16.random(in: 22...24)
        case .bowman:
            hp = UInt16.random(in: 20...24)
            mp = UInt16.random(in: 14...16)
        case .thief:
            hp = UInt16.random(in: 20...24)
            mp = UInt16.random(in: 14...16)
        case .pirate:
            hp = UInt16.random(in: 22...28)
            mp = UInt16.random(in: 18...23)
        default:
            hp = UInt16.random(in: 12...16)
            mp = UInt16.random(in: 10...12)
        }
        return (hp, mp)
    }

    /// SP granted when reaching certain job-advancement levels.
    private func spGranted(at level: UInt16, job: Job) -> Int {
        switch level {
        case 10: return job == .beginner ? 1 : 0  // 1st job advance
        case 30: return 3   // 2nd job advance hint
        case 70: return 3   // 3rd job advance hint
        case 120: return 3  // 4th job advance hint
        default: return 1   // normal SP per level after 1st job
        }
    }
}
