//
//  PartyOperationHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct PartyOperationHandler: PacketHandler {

    public typealias Packet = MapleStory83.PartyOperationRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        switch packet {
        case .create:
            if try await connection.party(for: character.id) != nil {
                try await connection.send(ServerMessageNotification.notice(message: "You are already in a party."))
                return
            }

            let channelValue: UInt8 = UInt8((await connection.channelIndex ?? 0) + 1)
            let party = try await connection.createParty(
                leaderID: character.id,
                leaderName: character.name,
                leaderJob: character.job,
                leaderLevel: character.level,
                channel: channelValue,
                map: character.currentMap
            )

            let memberEntities = try await connection.partyMembers(party.id)
            let members = memberEntities.map { $0.toPartyMember() }
            try await connection.send(PartyOperationNotification(
                operation: .create,
                partyID: party.partyID,
                members: members
            ))

        case .leave:
            guard let party = try await connection.party(for: character.id) else { return }

            let wasLeader = party.leaderID == character.id
            _ = try await connection.removePartyMember(character.id, from: party.id)
            let updatedParty = try await connection.loadParty(party.id)

            if wasLeader || updatedParty == nil {
                try await connection.send(PartyOperationNotification(operation: .disband, partyID: nil, members: []))
            } else {
                let memberEntities = try await connection.partyMembers(party.id)
                let members = memberEntities.map { $0.toPartyMember() }
                try await connection.send(PartyOperationNotification(
                    operation: .leave,
                    partyID: party.partyID,
                    members: members
                ))
            }

        case .accept(let partyID):
            guard try await connection.party(for: character.id) == nil else {
                try await connection.send(ServerMessageNotification.notice(message: "You are already in a party."))
                return
            }
            guard let party = try await connection.party(by: partyID) else {
                try await connection.send(ServerMessageNotification.notice(message: "The party you are trying to join does not exist."))
                return
            }
            let existingMembers = try await connection.partyMembers(party.id)
            guard existingMembers.count < 6 else {
                try await connection.send(ServerMessageNotification.notice(message: "The party is already full."))
                return
            }

            let channelValue: UInt8 = UInt8((await connection.channelIndex ?? 0) + 1)
            _ = try await connection.addPartyMember(
                character.id,
                name: character.name,
                job: character.job,
                level: character.level,
                channel: channelValue,
                map: character.currentMap,
                to: party.id
            )
            let memberEntities = try await connection.partyMembers(party.id)
            let members = memberEntities.map { $0.toPartyMember() }
            try await connection.send(PartyOperationNotification(
                operation: .accept,
                partyID: partyID,
                members: members
            ))

        case .invite(let invitedName):
            guard try await connection.party(for: character.id) != nil else { return }
            guard invitedName.isEmpty == false else { return }
            try await connection.send(ServerMessageNotification.notice(message: "Party invite sent to \(invitedName)."))

        case .expel(let targetCharacterID):
            guard let party = try await connection.party(for: character.id),
                  party.leaderID == character.id else {
                return
            }
            _ = try await connection.removePartyMember(targetCharacterID, from: party.id)
            let memberEntities = try await connection.partyMembers(party.id)
            let members = memberEntities.map { $0.toPartyMember() }
            try await connection.send(PartyOperationNotification(
                operation: .expel,
                partyID: party.partyID,
                members: members
            ))

        case .passLeader(let newLeaderID):
            guard let party = try await connection.party(for: character.id),
                  party.leaderID == character.id else {
                return
            }
            guard try await connection.transferPartyLeadership(party.id, to: newLeaderID) else { return }
            let memberEntities = try await connection.partyMembers(party.id)
            let members = memberEntities.map { $0.toPartyMember() }
            try await connection.send(PartyOperationNotification(
                operation: .passLeader,
                partyID: party.partyID,
                members: members
            ))

        case .disband:
            guard let party = try await connection.party(for: character.id),
                  party.leaderID == character.id else {
                return
            }
            try await connection.disbandParty(party.id)
            try await connection.send(PartyOperationNotification(operation: .disband, partyID: nil, members: []))
        }
    }
}
