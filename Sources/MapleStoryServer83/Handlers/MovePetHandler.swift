//
//  MovePetHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct MovePetHandler: PacketHandler {

    public typealias Packet = MapleStory83.MovePetRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        guard let mapID = await connection.mapID else { return }

        let petID = PetID(packet.petID)
        guard let spawnedPet = await PetRegistry.shared.spawnedPet(petID),
              spawnedPet.ownerID == character.id else {
            return
        }

        await PetRegistry.shared.updatePetPosition(
            petID,
            position: PetPosition(x: packet.startX, y: packet.startY)
        )

        guard let slot = await PetRegistry.shared.activeSlot(for: petID, ownerID: character.id) else {
            return
        }

        try await connection.broadcast(
            MovePetNotification(
                characterID: character.index,
                slot: slot,
                petID: packet.petID,
                movementData: []
            ),
            map: mapID
        )
    }
}
