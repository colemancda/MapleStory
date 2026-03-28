//
//  UseDoorHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct UseDoorHandler: PacketHandler {

    public typealias Packet = MapleStory83.UseDoorRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        guard packet.mode == 0 || packet.mode == 1 else { return }

        let predicates: [Character.Predicate] = [
            .index(packet.objectID),
            .world(character.world)
        ]
        let predicate = FetchRequest.Predicate.compound(.and(predicates.map { .init(predicate: $0) }))
        guard let doorOwner = try await connection.database.fetch(Character.self, predicate: predicate, fetchLimit: 1).first else {
            try await connection.send(ServerMessageNotification.notice(message: "That door has expired or doesn't exist."))
            try await connection.send(UpdateStatsNotification.enableActions)
            return
        }

        guard let door = await DoorRegistry.shared.find(ownerID: doorOwner.id, in: character.currentMap) else {
            try await connection.send(ServerMessageNotification.notice(message: "That door has expired or doesn't exist."))
            try await connection.send(UpdateStatsNotification.enableActions)
            return
        }

        if door.isExpired {
            await DoorRegistry.shared.remove(ownerID: doorOwner.id)
            try await connection.send(ServerMessageNotification.notice(message: "That door has expired."))
            try await connection.send(UpdateStatsNotification.enableActions)
            return
        }

        let partyMembers: [PartyMemberEntity]
        if let party = try await PartyRegistry.shared.party(for: character.id, in: connection.database) {
            partyMembers = try await PartyRegistry.shared.loadPartyMembers(party.id, from: connection.database)
        } else {
            partyMembers = []
        }

        guard door.canBeUsed(by: character.id, partyMembers: partyMembers) else {
            try await connection.send(ServerMessageNotification.notice(message: "You cannot use this door."))
            try await connection.send(UpdateStatsNotification.enableActions)
            return
        }

        let toTown = packet.mode == 0

        if toTown {
            try await connection.warp(to: door.townMapID, spawn: door.townPortalID)
        } else {
            try await connection.warp(to: door.fieldMapID, spawn: 0)
        }
    }
}
