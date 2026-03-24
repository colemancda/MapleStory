//
//  DropDataCache.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Mob drop entry from WZ data.
public struct MobDrop: Codable, Equatable, Hashable, Sendable {

    /// Item ID to drop (0 = meso)
    public let itemID: UInt32

    /// Drop chance (0-1,000,000)
    public let chance: UInt32

    /// Minimum quantity (for items that drop in stacks)
    public let minQuantity: UInt16

    /// Maximum quantity
    public let maxQuantity: UInt16

    public init(
        itemID: UInt32,
        chance: UInt32,
        minQuantity: UInt16 = 1,
        maxQuantity: UInt16 = 1
    ) {
        self.itemID = itemID
        self.chance = chance
        self.minQuantity = minQuantity
        self.maxQuantity = maxQuantity
    }

    /// Roll the drop chance and return true if successful.
    public func roll() -> Bool {
        let roll = UInt32.random(in: 0...1_000_000)
        return roll < chance
    }

    /// Get the actual dropped quantity (random between min and max).
    public func quantity() -> UInt16 {
        guard maxQuantity > minQuantity else {
            return minQuantity
        }
        return UInt16.random(in: minQuantity...maxQuantity)
    }
}

/// Cache for mob drop data loaded from WZ files.
public actor DropDataCache {

    public static let shared = DropDataCache()

    /// Mob ID -> List of possible drops
    private var drops = [UInt32: [MobDrop]]()

    /// Mob ID -> Meso drop chance
    private var mesoDropChance = [UInt32: UInt32]()

    private init() {}

    // MARK: - Loading

    /// Load drop data from WZ directory.
    /// Parses String.wz for drop data and Monster.wz for mob info.
    public func load(from stringWz: URL, monsterWz: URL) async {
        // For now, we'll load meso drop rates from Monster.wz
        // Full drop table parsing from String.wz can be added later
        await loadMesoDrops(from: monsterWz)
    }

    private func loadMesoDrops(from monsterWz: URL) async {
        // TODO: Parse Monster.wz to load meso drop rates
        // For now, use a default rate
        // This would involve parsing mob XML files and extracting meso drop data
    }

    // MARK: - Query

    /// Get all possible drops for a mob.
    public func drops(for mobID: UInt32) -> [MobDrop] {
        return drops[mobID] ?? []
    }

    /// Get meso drop chance for a mob.
    public func mesoDropChance(for mobID: UInt32) -> UInt32 {
        return mesoDropChance[mobID] ?? 0
    }

    /// Add drops for a mob (for testing or manual population).
    public func setDrops(_ newDrops: [MobDrop], for mobID: UInt32) {
        drops[mobID] = newDrops
    }

    /// Set meso drop chance for a mob.
    public func setMesoDropChance(_ chance: UInt32, for mobID: UInt32) {
        mesoDropChance[mobID] = chance
    }

    // MARK: - Drop Rolling

    /// Roll all drops for a mob and return successful ones.
    public func rollDrops(for mobID: UInt32) -> [(drop: MobDrop, quantity: UInt16)] {
        let allDrops = drops(for: mobID)
        var successful: [(drop: MobDrop, quantity: UInt16)] = []

        for drop in allDrops {
            if drop.roll() {
                successful.append((drop, drop.quantity()))
            }
        }

        return successful
    }

    /// Roll meso drop and return amount if successful.
    public func rollMeso(for mobID: UInt32, level: UInt8) -> UInt32? {
        let chance = mesoDropChance(for: mobID)
        guard chance > 0 else {
            return nil
        }

        // Roll drop chance
        let roll = UInt32.random(in: 0...1_000_000)
        guard roll < chance else {
            return nil
        }

        // Calculate meso amount based on mob level
        // Formula: level * level * 10 (basic formula, can be refined)
        let baseAmount = UInt32(level) * UInt32(level) * 10
        let variance = UInt32.random(in: 0...(baseAmount / 10))
        return baseAmount + variance
    }
}
