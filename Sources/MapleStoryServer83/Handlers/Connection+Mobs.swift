//
//  Connection+Mobs.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer
import MapleStoryServer62

extension MapMobRegistry.MobInstance {
    func toSpawnData() -> MobSpawnData {
        MobSpawnData(
            objectID: objectID,
            mobID: mobID,
            x: x,
            y: y,
            foothold: foothold,
            rx0: rx0,
            rx1: rx1,
            facing: facing
        )
    }
}

extension MapleStoryServer.Connection
where ClientOpcode == MapleStory83.ClientOpcode, ServerOpcode == MapleStory83.ServerOpcode {

    // MARK: - Mob Instances

    func mobInstance(objectID: UInt32) async -> MapMobRegistry.MobInstance? {
        await MapMobRegistry.shared.instance(objectID: objectID)
    }

    func mobController(for mapID: Map.ID) async -> MapleStoryAddress? {
        await MapMobRegistry.shared.controller(for: mapID)
    }

    func removeMob(objectID: UInt32) async {
        await MapMobRegistry.shared.remove(objectID: objectID)
    }

    func applyMobDamage(_ damage: UInt32, to objectID: UInt32) async -> MapMobRegistry.MobInstance? {
        await MapMobRegistry.shared.applyDamage(damage, to: objectID)
    }

    func nextMobObjectID() async -> UInt32 {
        await MapMobRegistry.shared.nextObjectID()
    }

    func addMob(_ instance: MapMobRegistry.MobInstance) async {
        await MapMobRegistry.shared.addMob(instance)
    }

    /// Returns true if the mob has a NEUTRALISE status effect active (stub).
    func mobIsNeutralised(objectID: UInt32) async -> Bool {
        return false
    }

    // MARK: - Mob Data

    func mobData(id: UInt32) async -> WzMob? {
        await MobDataCache.shared.mob(id: id)
    }
}
