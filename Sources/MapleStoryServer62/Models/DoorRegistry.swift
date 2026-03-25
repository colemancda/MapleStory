//
//  DoorRegistry.swift
//  MapleStoryServer62
//
//  Created by Coleman on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// Thread-safe registry for managing active Mystic Doors
public actor DoorRegistry {

    /// Shared singleton instance
    public static let shared = DoorRegistry()

    /// Active doors indexed by map ID
    private var doorsByMap: [Map.ID: [Character.ID: Door]] = [:]

    /// Active doors indexed by owner ID
    private var doorsByOwner: [Character.ID: Door] = [:]

    private init() {}

    /// Register a new door
    /// - Parameter door: The door to register
    public func register(_ door: Door) {
        // Remove existing door by same owner if exists
        if let existingDoor = doorsByOwner[door.ownerID] {
            remove(ownerID: door.ownerID)
        }

        // Add to owner index
        doorsByOwner[door.ownerID] = door

        // Add to field map index
        var fieldMapDoors = doorsByMap[door.fieldMapID, default: [:]]
        fieldMapDoors[door.ownerID] = door
        doorsByMap[door.fieldMapID] = fieldMapDoors

        // Add to town map index
        var townMapDoors = doorsByMap[door.townMapID, default: [:]]
        townMapDoors[door.ownerID] = door
        doorsByMap[door.townMapID] = townMapDoors
    }

    /// Remove a door by owner ID
    /// - Parameter ownerID: The ID of the door owner
    /// - Returns: The removed door, or nil if not found
    @discardableResult
    public func remove(ownerID: Character.ID) -> Door? {
        guard let door = doorsByOwner.removeValue(forKey: ownerID) else {
            return nil
        }

        // Remove from field map
        if var fieldMapDoors = doorsByMap[door.fieldMapID] {
            fieldMapDoors.removeValue(forKey: ownerID)
            doorsByMap[door.fieldMapID] = fieldMapDoors.isEmpty ? nil : fieldMapDoors
        }

        // Remove from town map
        if var townMapDoors = doorsByMap[door.townMapID] {
            townMapDoors.removeValue(forKey: ownerID)
            doorsByMap[door.townMapID] = townMapDoors.isEmpty ? nil : townMapDoors
        }

        return door
    }

    /// Find a door by owner ID in a specific map
    /// - Parameters:
    ///   - ownerID: The door owner's character ID
    ///   - mapID: The map to search in
    /// - Returns: The door if found, nil otherwise
    public func find(ownerID: Character.ID, in mapID: Map.ID) -> Door? {
        return doorsByMap[mapID]?[ownerID]
    }

    /// Get all doors in a specific map
    /// - Parameter mapID: The map ID
    /// - Returns: Array of doors in the map
    public func doors(in mapID: Map.ID) -> [Door] {
        guard let mapDoors = doorsByMap[mapID] else {
            return []
        }
        return Array(mapDoors.values)
    }

    /// Get a door by owner ID
    /// - Parameter ownerID: The door owner's character ID
    /// - Returns: The door if found, nil otherwise
    public func door(ownerID: Character.ID) -> Door? {
        return doorsByOwner[ownerID]
    }

    /// Clean up expired doors
    /// - Returns: Number of doors removed
    @discardableResult
    public func cleanExpiredDoors() -> Int {
        var removedCount = 0

        for (ownerID, door) in doorsByOwner {
            if door.isExpired {
                remove(ownerID: ownerID)
                removedCount += 1
            }
        }

        return removedCount
    }

    /// Remove all doors for a specific map
    /// - Parameter mapID: The map ID
    /// - Returns: Number of doors removed
    @discardableResult
    public func removeDoors(in mapID: Map.ID) -> Int {
        guard let mapDoors = doorsByMap[mapID] else {
            return 0
        }

        let count = mapDoors.count
        for ownerID in mapDoors.keys {
            remove(ownerID: ownerID)
        }

        return count
    }
}
