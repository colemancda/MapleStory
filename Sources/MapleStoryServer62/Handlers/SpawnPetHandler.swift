//
//  SpawnPetHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

/// Handles pet spawning/despawning from the cash inventory.
///
/// Players can spawn pets from their cash inventory to have them follow
/// the character in-game. This handler toggles pet visibility - spawning
/// an already-active pet will despawn it instead.
///
/// # Pet Spawning Flow
///
/// 1. Player double-clicks pet item in cash inventory
/// 2. Client sends spawn pet request with slot number
/// 3. Server validates pet item exists in slot
/// 4. If pet already active → despawn (toggle off)
/// 5. If pet inactive → spawn at player position (toggle on)
/// 6. Server broadcasts spawn/despawn to all map players
///
/// # Pet Slots
///
/// - Characters can have up to 3 active pets (slots 0, 1, 2)
/// - The "lead" pet is the primary one that follows closest
/// - Other pets follow at slightly different positions
///
/// # Pet Position
///
/// Pets spawn slightly above the player's position (y - 12) to
/// avoid overlapping with the character sprite.
///
/// # Broadcasting
///
/// Sends `SpawnPetNotification` to all players on the current map.
public struct SpawnPetHandler: PacketHandler {

    public typealias Packet = MapleStory62.SpawnPetRequest

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

        // Toggle pet: if this pet is already active, despawn it.
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
            let defaultName = "Pet"
            pet = await registry.createPet(
                itemID: itemID,
                name: defaultName,
                ownerID: character.id
            )
        }

        // Position slightly above player origin
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
