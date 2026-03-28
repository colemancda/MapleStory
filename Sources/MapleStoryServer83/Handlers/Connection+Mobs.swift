//
//  Connection+Mobs.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

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

    // MARK: - Mob Data

    func mobData(id: UInt32) async -> WzMob? {
        await MobDataCache.shared.mob(id: id)
    }
}
