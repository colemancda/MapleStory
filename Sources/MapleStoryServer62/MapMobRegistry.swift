//
//  MapMobRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Tracks live mob instances (spawned on maps) by their map object ID.
///
/// This is the runtime counterpart to `MobDataCache` (which holds templates).
/// Each entry is a spawned mob with its current HP derived from the template.
///
/// Mob instances are added when the server spawns them and removed when they die.
/// This actor is shared across the server process; map ID scoping prevents collisions.
public actor MapMobRegistry {

    public static let shared = MapMobRegistry()

    // MARK: - Types

    public struct MobInstance: Sendable {
        public let objectID: UInt32
        public let mobID: UInt32
        public let mapID: Map.ID
        public var currentHP: Int32
        public let maxHP: Int32
    }

    // MARK: - Storage

    /// Keyed by object ID.
    private var instances: [UInt32: MobInstance] = [:]

    private init() {}

    // MARK: - API

    /// Spawn a mob instance using stats from `MobDataCache`.
    /// Returns nil if the mob template is unknown.
    public func spawn(objectID: UInt32, mobID: UInt32, mapID: Map.ID) async -> MobInstance? {
        guard let template = await MobDataCache.shared.mob(id: mobID) else { return nil }
        let instance = MobInstance(
            objectID: objectID,
            mobID: mobID,
            mapID: mapID,
            currentHP: template.maxHP,
            maxHP: template.maxHP
        )
        instances[objectID] = instance
        return instance
    }

    /// Apply damage to a mob instance. Returns the updated instance, or nil if the object ID
    /// is unknown. The instance is removed from the registry when HP reaches 0.
    @discardableResult
    public func applyDamage(_ damage: UInt32, to objectID: UInt32) -> MobInstance? {
        guard var instance = instances[objectID] else { return nil }
        let dmg = Int32(min(damage, UInt32(Int32.max)))
        instance.currentHP = max(0, instance.currentHP - dmg)
        if instance.currentHP == 0 {
            instances.removeValue(forKey: objectID)
        } else {
            instances[objectID] = instance
        }
        return instance
    }

    /// Remove a mob instance (e.g. it left the map or the map unloaded).
    public func remove(objectID: UInt32) {
        instances.removeValue(forKey: objectID)
    }

    /// All live instances on a given map.
    public func instances(on mapID: Map.ID) -> [MobInstance] {
        instances.values.filter { $0.mapID == mapID }
    }

    public func instance(objectID: UInt32) -> MobInstance? {
        instances[objectID]
    }
}
