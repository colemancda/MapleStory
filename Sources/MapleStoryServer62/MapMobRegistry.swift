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
/// Each entry is a spawned mob with its current HP derived from the WZ template.
///
/// Mob instances are added when `spawnAll(for:from:)` is called on first player entry,
/// and removed when they die. The registry is shared across the server process;
/// map ID scoping prevents object ID collisions.
public actor MapMobRegistry {

    public static let shared = MapMobRegistry()

    // MARK: - Types

    public struct MobInstance: Sendable {
        public let objectID: UInt32
        public let mobID: UInt32
        public let mapID: Map.ID
        public var currentHP: Int32
        public let maxHP: Int32
        /// Spawn position X.
        public let x: Int16
        /// Spawn position Y (cy).
        public let y: Int16
        /// Foothold ID.
        public let foothold: UInt16
        /// Roam left bound.
        public let rx0: Int16
        /// Roam right bound.
        public let rx1: Int16
        /// 1 = face left, 0 = face right.
        public let facing: UInt8
        /// Respawn delay in seconds (0 = never respawn).
        public let mobTime: Int32
    }

    // MARK: - Storage

    /// Keyed by object ID.
    private var instances: [UInt32: MobInstance] = [:]

    /// Maps that have already been seeded so we don't double-spawn.
    private var seededMaps: Set<Map.ID> = []

    /// Controller address per map (the client responsible for moving all mobs on that map).
    private var controllers: [Map.ID: MapleStoryAddress] = [:]

    /// Monotonically increasing object ID counter. OdinMS starts at 1_000_000_000.
    private var nextObjectID: UInt32 = 1_000_000_000

    private init() {}

    // MARK: - Map Seeding

    /// Spawn all mob life entries from a WZ map if this map hasn't been seeded yet.
    /// Returns the newly created instances (empty if already seeded or no mob data).
    @discardableResult
    public func spawnAll(for mapID: Map.ID, from wzMap: WzMap) async -> [MobInstance] {
        guard !seededMaps.contains(mapID) else { return [] }
        seededMaps.insert(mapID)

        var spawned: [MobInstance] = []
        for life in wzMap.life where life.type == .mob && !life.hide {
            guard let mobIDValue = UInt32(life.id) else { continue }
            guard let template = await MobDataCache.shared.mob(id: mobIDValue) else { continue }

            let oid = nextObjectID
            nextObjectID &+= 1

            let instance = MobInstance(
                objectID: oid,
                mobID: mobIDValue,
                mapID: mapID,
                currentHP: template.maxHP,
                maxHP: template.maxHP,
                x: Int16(clamping: life.x),
                y: Int16(clamping: life.cy),
                foothold: UInt16(clamping: life.foothold),
                rx0: Int16(clamping: life.rx0),
                rx1: Int16(clamping: life.rx1),
                facing: life.facing != 0 ? 1 : 0,
                mobTime: life.mobTime
            )
            instances[oid] = instance
            spawned.append(instance)
        }
        return spawned
    }

    // MARK: - Controller Assignment

    /// Assign a controller for the given map. Returns all instances on the map
    /// so the caller can send `SpawnMonsterControl` to the new controller and
    /// `SpawnMonsterNotification` to everyone else.
    public func assignController(_ address: MapleStoryAddress, for mapID: Map.ID) -> [MobInstance] {
        controllers[mapID] = address
        return instances.values.filter { $0.mapID == mapID }
    }

    /// Remove a controller (e.g. player disconnected or left map).
    /// Returns the map ID if one was assigned to this address.
    @discardableResult
    public func removeController(address: MapleStoryAddress) -> Map.ID? {
        guard let entry = controllers.first(where: { $0.value == address }) else { return nil }
        controllers.removeValue(forKey: entry.key)
        return entry.key
    }

    public func controller(for mapID: Map.ID) -> MapleStoryAddress? {
        controllers[mapID]
    }

    // MARK: - Damage / Kill

    /// Apply damage to a mob instance. Returns the updated instance, or nil if unknown.
    /// The instance is removed from the registry when HP reaches 0.
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

    /// Remove a mob instance manually (map unload, etc.).
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
