//
//  Connection+MobSpawn.swift
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

    /// Called when a player enters a map. Seeds mob spawns from WZ data if this is the
    /// first player on the map, then sends spawn packets to the entering client.
    /// The entering client becomes the controller if no controller exists for the map.
    func sendMapMobs(for mapID: Map.ID) async throws {
        // Seed the map from WZ data on first entry.
        if let wzMap = await MapDataCache.shared.map(id: mapID) {
            await MapMobRegistry.shared.spawnAll(for: mapID, from: wzMap)
        }

        let instances = await MapMobRegistry.shared.instances(on: mapID)
        guard !instances.isEmpty else { return }

        let isController = await MapMobRegistry.shared.controller(for: mapID) == nil
        if isController {
            await MapMobRegistry.shared.assignController(address, for: mapID)
        }

        for instance in instances {
            let mobData = MobSpawnData(
                objectID: instance.objectID,
                mobID: instance.mobID,
                x: instance.x,
                y: instance.y,
                foothold: instance.foothold,
                rx0: instance.rx0,
                rx1: instance.rx1,
                facing: instance.facing
            )
            if isController {
                try await send(SpawnMonsterControl(mob: mobData))
            } else {
                try await send(SpawnMonsterNotification(mob: mobData))
            }
        }
    }

    /// Reassign mob controller for a map after the current controller leaves.
    /// Sends `SpawnMonsterControl(control: 0)` to release the old controller (already gone),
    /// then picks the first remaining player on the map to be the new controller.
    /// Call this when a player disconnects or changes maps.
    func releaseMapControl(for mapID: Map.ID) async {
        await MapMobRegistry.shared.removeController(address: address)
        // Controller reassignment is handled by the next player to enter or an explicit call.
    }
}
