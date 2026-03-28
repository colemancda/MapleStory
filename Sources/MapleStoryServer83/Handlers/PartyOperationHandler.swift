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
                return
            }

            let wasLeader = party.leaderID == character.id
            _ = try await PartyRegistry.shared.removeMember(character.id, from: party.id, in: connection.database)
            let updatedParty = try await PartyRegistry.shared.loadParty(party.id, from: connection.database)

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
            guard invitedName.isEmpty == false else { return }
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
