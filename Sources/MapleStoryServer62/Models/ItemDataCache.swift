//
//  ItemDataCache.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Errors that can occur when loading item data.
public enum ItemDataCacheError: Error, Sendable {
    case directoryNotFound(URL)
    case invalidFile(URL, underlying: Error)
}

/// Cache for item data loaded from WZ files.
public actor ItemDataCache {

    public static let shared = ItemDataCache()

    private var consumeItems = [UInt32: WzItemConsume]()
    private var equipItems = [UInt32: WzItemEquip]()

    private init() {}

    // MARK: - Loading

    /// Load item data from WZ directory
    public func load(from itemWz: URL) async throws {
        // Load consumable items
        try await loadConsumeItems(from: itemWz.appendingPathComponent("Consume"))

        // Load equipment items
        try await loadEquipItems(from: itemWz.appendingPathComponent("Equip"))
    }

    private func loadConsumeItems(from directory: URL) async throws {
        let fileManager = FileManager.default

        let files = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        )

        for file in files where file.pathExtension == "xml" {
            do {
                let items = try WzItemConsume.items(contentsOf: file)
                for item in items {
                    consumeItems[item.id] = item
                }
            } catch {
                throw ItemDataCacheError.invalidFile(file, underlying: error)
            }
        }
    }

    private func loadEquipItems(from directory: URL) async throws {
        let fileManager = FileManager.default

        let files = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        )

        for file in files where file.pathExtension == "xml" {
            do {
                let items = try WzItemEquip.items(contentsOf: file)
                for item in items {
                    equipItems[item.id] = item
                }
            } catch {
                throw ItemDataCacheError.invalidFile(file, underlying: error)
            }
        }
    }

    // MARK: - Query

    /// Get consume item data
    public func consume(id: UInt32) -> WzItemConsume? {
        return consumeItems[id]
    }

    /// Get equip item data
    public func equip(id: UInt32) -> WzItemEquip? {
        return equipItems[id]
    }

    /// Check if item exists
    public func exists(_ itemId: UInt32) -> Bool {
        return consumeItems[itemId] != nil || equipItems[itemId] != nil
    }

    /// Get max stack size for an item
    public func maxStackSize(for itemId: UInt32) -> Int32 {
        if let consume = consumeItems[itemId] {
            return consume.slotMax
        } else if let equip = equipItems[itemId] {
            return equip.slotMax
        }
        return 100 // Default max stack
    }

    /// Get item price
    public func price(for itemId: UInt32) -> Int32 {
        if let consume = consumeItems[itemId] {
            return consume.price
        } else if let equip = equipItems[itemId] {
            return equip.price
        }
        return 1 // Default price
    }

    /// Get inventory type for an item ID
    public func inventoryType(for itemId: UInt32) -> InventoryType? {
        let prefix = itemId / 1000000

        switch prefix {
        case 1: return .equip
        case 2: return .use
        case 3: return .setup
        case 4: return .etc
        case 5: return .cash
        default: return nil
        }
    }
}
