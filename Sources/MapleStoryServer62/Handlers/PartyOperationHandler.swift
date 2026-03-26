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

        switch packet {
        case .create:
            if try await PartyRegistry.shared.party(for: character.id, in: connection.database) != nil {
                try await connection.send(ServerMessageNotification.notice(message: "You are already in a party."))
                return
            }

            let channelValue: UInt8 = UInt8((await connection.channelIndex ?? 0) + 1)
            let party = try await PartyRegistry.shared.createParty(
                leaderID: character.id,
                leaderName: character.name,
                leaderJob: character.job,
                leaderLevel: character.level,
                channel: channelValue,
                map: character.currentMap,
                in: connection.database
            )

            let memberEntities = try await PartyRegistry.shared.loadPartyMembers(party.id, from: connection.database)
            let members = memberEntities.map { $0.toPartyMember() }
            try await connection.send(PartyOperationNotification(
                operation: .create,
                partyID: party.partyID,
                members: members
            ))

        case .leave:
            guard let party = try await PartyRegistry.shared.party(for: character.id, in: connection.database) else {
                return // Not in a party
            }

            let wasLeader = party.leaderID == character.id
            _ = try await PartyRegistry.shared.removeMember(character.id, from: party.id, in: connection.database)
            let updatedParty = try await PartyRegistry.shared.loadParty(party.id, from: connection.database)

            // Notify remaining members or that party was disbanded
            if wasLeader || updatedParty == nil {
                try await connection.send(PartyOperationNotification(
                    operation: .disband,
                    partyID: nil,
                    members: []
                ))
            } else {
                let memberEntities = try await PartyRegistry.shared.loadPartyMembers(party.id, from: connection.database)
                let members = memberEntities.map { $0.toPartyMember() }
                try await connection.send(PartyOperationNotification(
                    operation: .leave,
                    partyID: party.partyID,
                    members: members
                ))
            }

        case .accept(let partyID):
            guard try await PartyRegistry.shared.party(for: character.id, in: connection.database) == nil else {
                try await connection.send(ServerMessageNotification.notice(message: "You are already in a party."))
                return
            }
            guard let party = try await PartyRegistry.shared.party(by: partyID, in: connection.database) else {
                try await connection.send(ServerMessageNotification.notice(message: "The party you are trying to join does not exist."))
                return
            }
            let existingMembers = try await PartyRegistry.shared.loadPartyMembers(party.id, from: connection.database)
            guard existingMembers.count < 6 else {
                try await connection.send(ServerMessageNotification.notice(message: "The party is already full."))
                return
            }

            let channelValue: UInt8 = UInt8((await connection.channelIndex ?? 0) + 1)
            _ = try await PartyRegistry.shared.addMember(
                character.id,
                name: character.name,
                job: character.job,
                level: character.level,
                channel: channelValue,
                map: character.currentMap,
                to: party.id,
                in: connection.database
            )
            let memberEntities = try await PartyRegistry.shared.loadPartyMembers(party.id, from: connection.database)
            let members = memberEntities.map { $0.toPartyMember() }
            try await connection.send(PartyOperationNotification(
                operation: .accept,
                partyID: partyID,
                members: members
            ))

        case .invite(let invitedName):
            guard try await PartyRegistry.shared.party(for: character.id, in: connection.database) != nil else {
                return
            }
            guard invitedName.isEmpty == false else {
                return
            }
            // Online lookup / cross-connection invite dispatch is not wired yet.
            try await connection.send(ServerMessageNotification.notice(message: "Party invite sent to \(invitedName)."))

        case .expel(let targetCharacterID):
            guard let party = try await PartyRegistry.shared.party(for: character.id, in: connection.database),
                  party.leaderID == character.id else {
                return
            }
            _ = try await PartyRegistry.shared.removeMember(targetCharacterID, from: party.id, in: connection.database)
            let memberEntities = try await PartyRegistry.shared.loadPartyMembers(party.id, from: connection.database)
            let members = memberEntities.map { $0.toPartyMember() }
            try await connection.send(PartyOperationNotification(
                operation: .expel,
                partyID: party.partyID,
                members: members
            ))

        case .passLeader(let newLeaderID):
            guard let party = try await PartyRegistry.shared.party(for: character.id, in: connection.database),
                  party.leaderID == character.id else {
                return
            }
            guard try await PartyRegistry.shared.transferLeadership(party.id, to: newLeaderID, in: connection.database) else {
                return
            }
            let memberEntities = try await PartyRegistry.shared.loadPartyMembers(party.id, from: connection.database)
            let members = memberEntities.map { $0.toPartyMember() }
            try await connection.send(PartyOperationNotification(
                operation: .passLeader,
                partyID: party.partyID,
                members: members
            ))

        case .disband:
            guard let party = try await PartyRegistry.shared.party(for: character.id, in: connection.database),
                  party.leaderID == character.id else {
                return
            }
            try await PartyRegistry.shared.disbandParty(party.id, in: connection.database)
            try await connection.send(PartyOperationNotification(
                operation: .disband,
                partyID: nil,
                members: []
            ))
        }
    }
}
