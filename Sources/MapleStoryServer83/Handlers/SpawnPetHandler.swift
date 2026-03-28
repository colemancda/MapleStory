//
//  SpawnPetHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct SpawnPetHandler: PacketHandler {

    public typealias Packet = MapleStory83.SpawnPetRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        let inventory = await character.getInventory()
        let inventorySlot = Int8(bitPattern: packet.slot)
        guard let cashItem = inventory.cash[inventorySlot] else {
            return
        }

        let itemID = cashItem.itemId
        let registry = PetRegistry.shared

        if let existing = await registry.pet(ownerID: character.id, itemID: itemID),
           let slot = await registry.activeSlot(for: existing.id, ownerID: character.id) {
            await registry.despawnPet(existing.id)
            try await connection.broadcast(
                SpawnPetNotification(
                    characterID: character.index,
                    slot: slot,
                    remove: true,
                    hunger: false
                ),
                map: character.currentMap
            )
            return
        }

        let pet: Pet
        if let ownedPet = await registry.pet(ownerID: character.id, itemID: itemID) {
            pet = ownedPet
        } else {
            pet = await registry.createPet(itemID: itemID, name: "Pet", ownerID: character.id)
        }

        let playerPosition = await PlayerPositionRegistry.shared.position(for: character.id)
        let petPosition = PetPosition(
            x: playerPosition?.x ?? 0,
            y: (playerPosition?.y ?? 0) - 12
        )

        guard let activeSlot = await registry.spawnPet(
            pet.id,
            ownerID: character.id,
            lead: packet.isLead == 1,
            position: petPosition
        ) else {
            return
        }

        try await connection.broadcast(
            SpawnPetNotification(
                characterID: character.index,
                slot: activeSlot,
                remove: false,
                itemID: pet.itemID,
                name: pet.name,
                uniqueID: UInt32(truncatingIfNeeded: pet.id),
                positionX: petPosition.x,
                positionY: petPosition.y,
                stance: 0,
                foothold: 0
            ),
            map: character.currentMap
        )
    }
}
