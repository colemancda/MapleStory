//
//  Connection+Pets.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

extension MapleStoryServer.Connection
where ClientOpcode == MapleStory83.ClientOpcode, ServerOpcode == MapleStory83.ServerOpcode {

    func pet(ownerID: Character.ID, itemID: UInt32) async -> Pet? {
        await PetRegistry.shared.pet(ownerID: ownerID, itemID: itemID)
    }

    func createPet(itemID: UInt32, name: String, ownerID: Character.ID) async -> Pet {
        await PetRegistry.shared.createPet(itemID: itemID, name: name, ownerID: ownerID)
    }

    func spawnedPet(_ petID: PetID) async -> Pet? {
        await PetRegistry.shared.spawnedPet(petID)
    }

    func activePetSlot(for petID: PetID, ownerID: Character.ID) async -> UInt8? {
        await PetRegistry.shared.activeSlot(for: petID, ownerID: ownerID)
    }

    @discardableResult
    func spawnPet(_ petID: PetID, ownerID: Character.ID, lead: Bool, position: PetPosition) async -> Bool {
        await PetRegistry.shared.spawnPet(petID, ownerID: ownerID, lead: lead, position: position)
    }

    func despawnPet(_ petID: PetID) async {
        await PetRegistry.shared.despawnPet(petID)
    }

    func updatePetPosition(_ petID: PetID, position: PetPosition) async {
        await PetRegistry.shared.updatePetPosition(petID, position: position)
    }
}
