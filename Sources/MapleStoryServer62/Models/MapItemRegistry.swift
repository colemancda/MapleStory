//
//  MapItemRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// Registry tracking all dropped items on all maps.
public actor MapItemRegistry {

    public static let shared = MapItemRegistry()

    /// Map ID -> Map Items on that map
    private var items = [Map.ID: [UInt32: MapItem]]()

    /// Object ID counter for generating unique drop IDs
    private var nextObjectID: UInt32 = 100_000

    private init() {}

    // MARK: - Drop Management

    /// Create a new drop on a map.
    @discardableResult
    public func createDrop(
        itemID: UInt32,
        quantity: UInt32,
        ownerID: UInt32,
        position: DropPosition,
        mapID: Map.ID,
        duration: TimeInterval = 180.0
    ) -> MapItem {
        let objectID = nextObjectID
        nextObjectID = nextObjectID &+ 1

        let expiry = Date().addingTimeInterval(duration)

        let mapItem = MapItem(
            objectID: objectID,
            itemID: itemID,
            quantity: quantity,
            ownerID: ownerID,
            position: position,
            expiry: expiry,
            mapID: mapID
        )

        // Add to registry
        if items[mapID] == nil {
            items[mapID] = [:]
        }
        items[mapID]?[objectID] = mapItem

        return mapItem
    }

    /// Remove a drop from the map (picked up or expired).
    public func removeDrop(objectID: UInt32, from mapID: Map.ID) {
        items[mapID]?[objectID] = nil
    }

    /// Get a specific drop.
    public func drop(objectID: UInt32, on mapID: Map.ID) -> MapItem? {
        return items[mapID]?[objectID]
    }

    /// Get all drops on a map.
    public func drops(on mapID: Map.ID) -> [MapItem] {
        guard let mapItems = items[mapID] else {
            return []
        }
        return Array(mapItems.values)
    }

    /// Remove expired drops from a map.
    public func cleanupExpired(on mapID: Map.ID) {
        guard var mapItems = items[mapID] else {
            return
        }

        let now = Date()
        mapItems = mapItems.filter { _, item in
            item.expiry > now
        }

        items[mapID] = mapItems
    }

    /// Clear all drops on a map (map change).
    public func clearMap(_ mapID: Map.ID) {
        items[mapID] = nil
    }
}
