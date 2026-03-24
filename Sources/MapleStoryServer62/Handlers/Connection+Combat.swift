//
//  Connection+Combat.swift
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

    /// Process attack hits against mob instances.
    /// - Parameters:
    ///   - targets: Map of mob object ID → list of individual hit damage values.
    ///   - mapID: The map the attacker is on (for broadcast scoping).
    ///   - useMagicDefense: Use magic defense cap instead of physical (for magic attacks).
    func processAttack(
        targets: [UInt32: [UInt32]],
        mapID: Map.ID,
        useMagicDefense: Bool = false
    ) async throws {
        for (objectID, damages) in targets {
            let totalDamage = damages.reduce(0, +)
            guard totalDamage > 0 else { continue }

            let validatedDamage: UInt32
            if let instance = await MapMobRegistry.shared.instance(objectID: objectID),
               let template = await MobDataCache.shared.mob(id: instance.mobID) {
                let cap = UInt32(max(0, useMagicDefense ? template.maDamage : template.paDamage))
                // Use maxHP as fallback cap so damage can't exceed full mob HP in one hit.
                let hpCap = UInt32(max(0, template.maxHP))
                let effectiveCap = cap > 0 ? min(cap, hpCap) : hpCap
                validatedDamage = effectiveCap > 0 ? min(totalDamage, effectiveCap) : totalDamage
            } else {
                validatedDamage = totalDamage
            }

            try await broadcast(DamageMonsterNotification(objectID: objectID, damage: validatedDamage), map: mapID)

            let updated = await MapMobRegistry.shared.applyDamage(validatedDamage, to: objectID)
            if let updated, updated.currentHP == 0 {
                try await broadcast(KillMonsterNotification(objectID: objectID), map: mapID)
            }
        }
    }
}
