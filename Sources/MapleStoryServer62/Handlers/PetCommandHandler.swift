//
//  PetCommandHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct PetCommandHandler: PacketHandler {

    public typealias Packet = MapleStory62.PetCommandRequest

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
        guard let slot = await PetRegistry.shared.activeSlot(for: petID, ownerID: character.id) else {
            return
        }

        // Default to success until per-pet command probability data is implemented.
        try await connection.broadcast(
            PetCommandNotification(
                characterID: character.index,
                slot: slot,
                isFoodCommand: false,
                command: packet.command,
                success: true
            ),
            map: mapID
        )
    }
}
