//
//  BuddyListModifyHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct BuddyListModifyHandler: PacketHandler {

    public typealias Packet = MapleStory83.BuddyListModifyRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        switch packet {
        case .add(let name):
            try await handleAddBuddy(name: name, character: character, connection: connection)

        case .accept(let characterID):
            try await handleAcceptBuddy(characterID: characterID, character: character, connection: connection)

        case .remove(let characterID):
            try await handleRemoveBuddy(characterID: characterID, character: character, connection: connection)
        }
    }

    private func handleAddBuddy<Socket: MapleStorySocket, Database: ModelStorage>(
        name: String,
        character: Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let characterName = CharacterName(rawValue: name) else {
            try await connection.send(BuddyListMessageNotification.characterNotFound)
            return
        }

        if try await connection.isBuddyListFull(character.id, capacity: character.buddyCapacity) {
            try await connection.send(BuddyListMessageNotification.buddyListFull)
            return
        }

        let predicates: [Character.Predicate] = [.name(characterName), .world(character.world)]
        let predicate = FetchRequest.Predicate.compound(.and(predicates.map { .init(predicate: $0) }))

        guard let otherCharacter = try await connection.database.fetch(Character.self, predicate: predicate, fetchLimit: 1).first,
              otherCharacter.id != character.id else {
            try await connection.send(BuddyListMessageNotification.characterNotFound)
            return
        }

        if try await connection.buddyListContains(buddyID: otherCharacter.index, in: character.id) {
            try await connection.send(BuddyListMessageNotification.alreadyOnList)
            return
        }

        if try await connection.isBuddyListFull(otherCharacter.id, capacity: otherCharacter.buddyCapacity) {
            try await connection.send(BuddyListMessageNotification.otherBuddyListFull)
            return
        }

        let senderBuddy = Buddy(character: character.id, buddyID: otherCharacter.index, pending: true)
        _ = try await connection.addBuddy(senderBuddy, to: character.id)

        let targetBuddy = Buddy(character: otherCharacter.id, buddyID: character.index, pending: true)
        _ = try await connection.addBuddy(targetBuddy, to: otherCharacter.id)

        _ = await connection.addPendingBuddyRequest(from: character.index, fromName: character.name, to: otherCharacter.id)

        let list = try await connection.buddyListNotification(for: character.id)
        try await connection.send(BuddyListNotification.update(list))
    }

    private func handleAcceptBuddy<Socket: MapleStorySocket, Database: ModelStorage>(
        characterID: UInt32,
        character: Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        if try await connection.isBuddyListFull(character.id, capacity: character.buddyCapacity) {
            try await connection.send(BuddyListMessageNotification.buddyListFull)
            return
        }

        guard let otherCharacter = try await Character.fetch(characterID, world: character.world, in: connection.database),
              otherCharacter.id != character.id else {
            return
        }

        let updated = try await connection.updateBuddyPending(buddyID: characterID, for: character.id, pending: false)
        guard updated else { return }

        _ = try await connection.updateBuddyPending(buddyID: character.index, for: otherCharacter.id, pending: false)
        _ = await connection.removePendingBuddyRequest(from: characterID, to: character.id)

        let list = try await connection.buddyListNotification(for: character.id)
        try await connection.send(BuddyListNotification.update(list))
    }

    private func handleRemoveBuddy<Socket: MapleStorySocket, Database: ModelStorage>(
        characterID: UInt32,
        character: Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let removed = try await connection.removeBuddy(buddyID: characterID, from: character.id)
        guard removed else { return }

        if let otherCharacter = try await Character.fetch(characterID, world: character.world, in: connection.database) {
            _ = try await connection.removeBuddy(buddyID: character.index, from: otherCharacter.id)
        }

        let list = try await connection.buddyListNotification(for: character.id)
        try await connection.send(BuddyListNotification.update(list))
    }
}
