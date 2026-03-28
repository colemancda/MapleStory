//
//  PetCommandHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct PetCommandHandler: PacketHandler {

    public typealias Packet = MapleStory83.PetCommandRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }
        guard let mapID = await connection.mapID else { return }

        let petID = PetID(packet.petID)
        guard let spawnedPet = await connection.spawnedPet(petID),
              spawnedPet.ownerID == character.id else {
            return
        }
        guard let slot = await connection.activePetSlot(for: petID, ownerID: character.id) else {
            return
        }

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
