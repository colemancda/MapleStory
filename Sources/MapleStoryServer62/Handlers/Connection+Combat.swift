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

// Type alias for MobInstance
private typealias MobInstance = MapMobRegistry.MobInstance

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

                // Award experience for the kill.
                if let template = await MobDataCache.shared.mob(id: updated.mobID) {
                    let exp = UInt32(max(0, template.exp))
                    if exp > 0 {
                        try await gainExp(exp)
                    }

                    // Spawn drops
                    await spawnDrops(from: updated, mapID: mapID)
                }

                // Remove mob from registry
                await MapMobRegistry.shared.remove(objectID: objectID)
            }
        }
    }

    // MARK: - Drop Spawning

    /// Spawn drops from a killed mob.
    private func spawnDrops(
        from mobInstance: MobInstance,
        mapID: Map.ID
    ) async {
        let position = DropPosition(x: mobInstance.x, y: mobInstance.y)

        // Roll meso drop
        if let mesoAmount = await DropDataCache.shared.rollMeso(
            for: mobInstance.mobID,
            level: 0 // TODO: Pass actual mob level
        ) {
            let drop = await MapItemRegistry.shared.createDrop(
                itemID: 0, // 0 = meso
                quantity: mesoAmount,
                ownerID: 0, // Anyone can pick up
                position: position,
                mapID: mapID
            )

            // TODO: Broadcast SpawnMapItemNotification for meso drop
            // For now, meso drops use a different packet opcode
        }

        // Roll item drops
        let successfulDrops = await DropDataCache.shared.rollDrops(for: mobInstance.mobID)

        for (dropData, quantity) in successfulDrops {
            let drop = await MapItemRegistry.shared.createDrop(
                itemID: dropData.itemID,
                quantity: UInt32(quantity),
                ownerID: 0, // Anyone can pick up (TODO: party drops)
                position: position,
                mapID: mapID
            )

            // Broadcast drop to map
            // TODO: Broadcast SpawnMapItemNotification (opcode dropItemFromMapObject)
            // Packet structure: objectID, itemID, quantity, ownerID, position, expiry
        }
    }
}
