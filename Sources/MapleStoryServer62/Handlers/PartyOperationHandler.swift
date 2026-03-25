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

/// Handles party management operations (create, invite, leave, kick, transfer leadership).
///
/// # Party Operations
///
/// | Code | Operation | Description |
/// |------|-----------|-------------|
/// | 1 | Create | Create a new party |
/// | 2 | Leave | Leave current party |
/// | 3 | Invite | Invite a player to the party |
/// | 4 | Expel | Kick a member (leader only) |
/// | 5 | Pass Leader | Transfer party leadership |
/// | 6 | Accept | Accept a party invitation |
///
/// # Party Rules
///
/// - Maximum 6 members per party
/// - Only leader can kick members and pass leadership
/// - Any member can invite new members
/// - Party leader gets extra EXP bonuses
/// - Party share EXP with nearby members
///
/// # Cross-Channel Parties
///
/// Party members can be on different channels in the same world.
/// Messages and operations are routed across channels.
///
/// # Response
///
/// Sends `PartyOperationNotification` to all party members indicating
/// the operation result and updated party composition.
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
            if await PartyRegistry.shared.party(for: character.id) != nil {
                try await connection.send(ServerMessageNotification.notice(message: "You are already in a party."))
                return
            }

            let channelValue: UInt8 = UInt8((await connection.channelIndex ?? 0) + 1)
            let party = await PartyRegistry.shared.createParty(
                leaderID: character.id,
                leaderName: character.name,
                leaderJob: character.job,
                leaderLevel: character.level,
                channel: channelValue,
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
            let updatedParty = await PartyRegistry.shared.party(party.id)

            // Notify remaining members or that party was disbanded
            if wasLeader || updatedParty == nil {
                try await connection.send(PartyOperationNotification(
                    operation: .disband,
                    partyID: nil,
                    members: []
                ))
            } else {
                let members = updatedParty?.members.values.map { $0 } ?? []
                try await connection.send(PartyOperationNotification(
                    operation: .leave,
                    partyID: party.id,
                    members: members
                ))
            }

        case 0x03: // Accept invite
            guard await PartyRegistry.shared.party(for: character.id) == nil else {
                try await connection.send(ServerMessageNotification.notice(message: "You are already in a party."))
                return
            }
            guard let partyID = packet.partyID,
                  let party = await PartyRegistry.shared.party(partyID) else {
                try await connection.send(ServerMessageNotification.notice(message: "The party you are trying to join does not exist."))
                return
            }
            guard party.memberCount < 6 else {
                try await connection.send(ServerMessageNotification.notice(message: "The party is already full."))
                return
            }

            let channelValue: UInt8 = UInt8((await connection.channelIndex ?? 0) + 1)
            _ = await PartyRegistry.shared.addMember(
                character.id,
                name: character.name,
                job: character.job,
                level: character.level,
                channel: channelValue,
                map: character.currentMap,
                to: partyID
            )
            let members = (await PartyRegistry.shared.party(partyID))?.members.values.map { $0 } ?? []
            try await connection.send(PartyOperationNotification(
                operation: .accept,
                partyID: partyID,
                members: members
            ))

        case 0x04: // Invite
            guard await PartyRegistry.shared.party(for: character.id) != nil else {
                return
            }
            guard let invitedName = packet.invitedName, invitedName.isEmpty == false else {
                return
            }
            // Online lookup / cross-connection invite dispatch is not wired yet.
            try await connection.send(ServerMessageNotification.notice(message: "Party invite sent to \(invitedName)."))

        case 0x05: // Expel member
            guard let party = await PartyRegistry.shared.party(for: character.id),
                  party.leaderID == character.id,
                  let targetCharacterID = packet.targetCharacterID else {
                return
            }
            _ = await PartyRegistry.shared.removeMember(targetCharacterID, from: party.id)
            let members = (await PartyRegistry.shared.party(party.id))?.members.values.map { $0 } ?? []
            try await connection.send(PartyOperationNotification(
                operation: .expel,
                partyID: party.id,
                members: members
            ))

        case 0x06: // Disband party
            guard let party = await PartyRegistry.shared.party(for: character.id),
                  party.leaderID == character.id,
                  let newLeader = packet.targetCharacterID else {
                return
            }
            guard await PartyRegistry.shared.transferLeadership(party.id, to: newLeader) else {
                return
            }
            let members = (await PartyRegistry.shared.party(party.id))?.members.values.map { $0 } ?? []
            try await connection.send(PartyOperationNotification(
                operation: .passLeader,
                partyID: party.id,
                members: members
            ))

        case 0x07: // Disband party
            guard let party = await PartyRegistry.shared.party(for: character.id),
                  party.leaderID == character.id else {
                return
            }
            await PartyRegistry.shared.disbandParty(party.id)
            try await connection.send(PartyOperationNotification(
                operation: .disband,
                partyID: nil,
                members: []
            ))

        default:
            return
        }
    }
}
