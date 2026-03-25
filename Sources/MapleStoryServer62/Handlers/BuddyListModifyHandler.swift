//
//  BuddyListModifyHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct BuddyListModifyHandler: PacketHandler {

    public typealias Packet = MapleStory62.BuddyListModifyRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let character = try await connection.character else { return }

        switch packet {
        case .add(let name):
            guard let characterName = CharacterName(rawValue: name) else {
                return
            }
            let predicates: [Character.Predicate] = [
                .name(characterName),
                .world(character.world)
            ]
            let predicate = FetchRequest.Predicate.compound(.and(predicates.map { .init(predicate: $0) }))
            guard let otherCharacter = try await connection.database.fetch(Character.self, predicate: predicate, fetchLimit: 1).first,
                  otherCharacter.id != character.id else {
                try await connection.send(ServerMessageNotification.notice(message: "Character not found."))
                return
            }
            let added = await BuddyListRegistry.shared.add(
                BuddyListNotification.Buddy(
                    id: otherCharacter.index,
                    name: otherCharacter.name,
                    value0: 0,
                    channel: -1
                ),
                to: character.id
            )
            if added == false {
                try await connection.send(ServerMessageNotification.notice(message: "\(otherCharacter.name.rawValue) is already in your buddy list."))
                return
            }
            let list = await BuddyListRegistry.shared.list(for: character.id)
            try await connection.send(BuddyListNotification.update(list))

        case .accept(let characterID):
            guard let otherCharacter = try await Character.fetch(
                characterID,
                world: character.world,
                in: connection.database
            ),
                  otherCharacter.id != character.id else {
                return
            }
            _ = await BuddyListRegistry.shared.add(
                BuddyListNotification.Buddy(
                    id: otherCharacter.index,
                    name: otherCharacter.name,
                    value0: 0,
                    channel: -1
                ),
                to: character.id
            )
            let list = await BuddyListRegistry.shared.list(for: character.id)
            try await connection.send(BuddyListNotification.update(list))

        case .remove(let characterID):
            _ = await BuddyListRegistry.shared.remove(buddyID: characterID, from: character.id)
            let list = await BuddyListRegistry.shared.list(for: character.id)
            try await connection.send(BuddyListNotification.update(list))
        }
    }
}
