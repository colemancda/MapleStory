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

    /// Get spawned pet by ID
    public func spawnedPet(_ petID: PetID) -> Pet? {
        return spawnedPets[petID]
    }

    /// Spawn a pet (make visible)
    public func spawnPet(_ petID: PetID, ownerID: Character.ID) -> Bool {
        guard let pets = ownedPets[ownerID],
              let pet = pets.first(where: { $0.id == petID }) else {
            return false
        }

        var spawned = pet
        spawned.isSpawned = true
        spawnedPets[petID] = spawned
        return true
    }

    /// Despawn a pet
    public func despawnPet(_ petID: PetID) {
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
