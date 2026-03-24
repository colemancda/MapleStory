//
//  PetRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// Registry for managing pets
public actor PetRegistry {

    public static let shared = PetRegistry()

    /// Character ID -> Array of owned pets
    private var ownedPets: [Character.ID: [Pet]] = [:]

    /// Currently spawned pets (Pet ID -> Pet)
    private var spawnedPets: [PetID: Pet] = [:]

    /// Character ID -> active pet IDs in visual slot order (0...2).
    private var activePetSlots: [Character.ID: [PetID]] = [:]

    /// Next pet ID
    private var nextPetID: PetID = 1

    private init() {}

    // MARK: - Pet Management

    /// Create a new pet (from cash shop or item)
    public func createPet(
        itemID: UInt32,
        name: String,
        ownerID: Character.ID,
        expiration: Date? = nil
    ) -> Pet {
        let pet = Pet(
            id: nextPetID,
            itemID: itemID,
            name: name,
            ownerID: ownerID,
            level: 1,
            closeness: 0,
            fullness: 100,
            expiration: expiration
        )
        nextPetID += 1

        if ownedPets[ownerID] == nil {
            ownedPets[ownerID] = []
        }
        ownedPets[ownerID]?.append(pet)

        return pet
    }

    /// Get all owned pets for a character
    public func pets(for ownerID: Character.ID) -> [Pet] {
        return ownedPets[ownerID] ?? []
    }

    /// Find owned pet by item ID.
    public func pet(ownerID: Character.ID, itemID: UInt32) -> Pet? {
        ownedPets[ownerID]?.first { $0.itemID == itemID }
    }

    /// Get spawned pet by ID
    public func spawnedPet(_ petID: PetID) -> Pet? {
        return spawnedPets[petID]
    }

    /// Get all spawned pets for a character in active slot order.
    public func spawnedPets(for ownerID: Character.ID) -> [Pet] {
        let slots = activePetSlots[ownerID] ?? []
        return slots.compactMap { spawnedPets[$0] }
    }

    /// Get active slot index for a specific pet.
    public func activeSlot(for petID: PetID, ownerID: Character.ID) -> UInt8? {
        guard let index = activePetSlots[ownerID]?.firstIndex(of: petID) else {
            return nil
        }
        return UInt8(index)
    }

    /// Spawn a pet (make visible)
    public func spawnPet(_ petID: PetID, ownerID: Character.ID) -> Bool {
        return spawnPet(petID, ownerID: ownerID, lead: false, position: nil) != nil
    }

    /// Spawn a pet with explicit lead/slot semantics.
    /// - Returns: Active slot index (0...2) on success.
    public func spawnPet(
        _ petID: PetID,
        ownerID: Character.ID,
        lead: Bool,
        position: PetPosition?
    ) -> UInt8? {
        guard let pets = ownedPets[ownerID],
              let pet = pets.first(where: { $0.id == petID }) else {
            return nil
        }

        // Already active: optionally update position and return current slot.
        if var existing = spawnedPets[petID] {
            if let position {
                existing.position = position
                spawnedPets[petID] = existing
            }
            return activeSlot(for: petID, ownerID: ownerID)
        }

        var slots = activePetSlots[ownerID] ?? []
        guard slots.count < 3 else { return nil }

        if lead {
            slots.insert(petID, at: 0)
        } else {
            slots.append(petID)
        }

        // Keep only first 3 in case of defensive misuse.
        if slots.count > 3 {
            slots = Array(slots.prefix(3))
        }

        var spawned = pet
        spawned.isSpawned = true
        if let position {
            spawned.position = position
        }
        spawnedPets[petID] = spawned
        activePetSlots[ownerID] = slots

        // Mirror spawned state in owned storage.
        if let index = ownedPets[ownerID]?.firstIndex(where: { $0.id == petID }) {
            ownedPets[ownerID]?[index] = spawned
        }

        guard let slot = slots.firstIndex(of: petID) else {
            return nil
        }
        return UInt8(slot)
    }

    /// Despawn a pet
    public func despawnPet(_ petID: PetID) {
        if let pet = spawnedPets[petID] {
            if let index = ownedPets[pet.ownerID]?.firstIndex(where: { $0.id == petID }) {
                var updated = ownedPets[pet.ownerID]![index]
                updated.isSpawned = false
                ownedPets[pet.ownerID]![index] = updated
            }
            activePetSlots[pet.ownerID]?.removeAll(where: { $0 == petID })
            if activePetSlots[pet.ownerID]?.isEmpty == true {
                activePetSlots[pet.ownerID] = nil
            }
        }
        spawnedPets.removeValue(forKey: petID)
    }

    /// Update pet position
    public func updatePetPosition(_ petID: PetID, position: PetPosition) {
        guard var pet = spawnedPets[petID] else { return }
        pet.position = position
        spawnedPets[petID] = pet
    }

    /// Feed pet (increases fullness)
    public func feedPet(_ petID: PetID) -> Bool {
        guard var pet = spawnedPets[petID] else { return false }

        pet.fullness = min(100, pet.fullness + 30)
        spawnedPets[petID] = pet

        // Also update in owned pets
        if let index = ownedPets[pet.ownerID]?.firstIndex(where: { $0.id == petID }) {
            ownedPets[pet.ownerID]?[index] = pet
        }

        return true
    }

    /// Decrease pet fullness over time (called periodically)
    public func decreaseFullness() {
        for petID in spawnedPets.keys {
            guard var pet = spawnedPets[petID] else { continue }

            if pet.fullness > 0 {
                pet.fullness -= 1
                spawnedPets[petID] = pet

                // Also update in owned pets
                if let index = ownedPets[pet.ownerID]?.firstIndex(where: { $0.id == petID }) {
                    ownedPets[pet.ownerID]?[index] = pet
                }
            }
        }
    }

    /// Load pets from database
    public func loadPets(from database: some ModelStorage) async throws {
        // TODO: Implement database loading
    }

    /// Save pets to database
    public func savePets(to database: some ModelStorage) async throws {
        // TODO: Implement database saving
    }
}
