//
//  PartyOperationHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct PartyOperationHandler: PacketHandler {

    public typealias Packet = MapleStory62.PartyOperationRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        switch packet.operation {
        case 0x01: // Create party
            let party = await PartyRegistry.shared.createParty(
                leaderID: character.id,
                leaderName: character.name,
                leaderJob: character.job,
                leaderLevel: character.level,
                channel: 0, // TODO: Get actual channel ID
                map: character.currentMap
            )

            let members = party.members.values.map { $0 }
            try await connection.send(PartyOperationNotification(
                operation: .create,
                partyID: party.id,
                members: members
            ))

        case 0x02: // Leave party
            guard let party = await PartyRegistry.shared.party(for: character.id) else {
                return // Not in a party
            }

            let wasLeader = party.leaderID == character.id
            await PartyRegistry.shared.removeMember(character.id, from: party.id)

            // Notify remaining members or that party was disbanded
            if wasLeader || party.memberCount == 1 {
                try await connection.send(PartyOperationNotification(
                    operation: .disband,
                    partyID: nil,
                    members: []
                ))
            } else {
                var updatedParty = await PartyRegistry.shared.party(party.id)
                let members = updatedParty?.members.values.map { $0 } ?? []
                try await connection.send(PartyOperationNotification(
                    operation: .leave,
                    partyID: party.id,
                    members: members
                ))
            }

        case 0x04: // Invite (handled by AcceptPartyRequestHandler)
            fallthrough
        case 0x03: // Accept invite
            // These are handled by dedicated handlers
            return

        case 0x05: // Expel member
            // Would need target character ID from packet
            // For now, stub implementation
            return

        case 0x06: // Disband party
            guard let party = await PartyRegistry.shared.party(for: character.id) else {
                return // Not in a party
            }

            guard party.leaderID == character.id else {
                return // Not leader
            }

            await PartyRegistry.shared.disbandParty(party.id)
            try await connection.send(PartyOperationNotification(
                operation: .disband,
                partyID: nil,
                members: []
            ))

        case 0x07: // Pass leadership
            // Would need target character ID from packet
            // For now, stub implementation
            return

        default:
            return
        }
    }
}
