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

/// Handles buddy list modifications (add, accept, remove).
///
/// # Buddy List System
///
/// The buddy list allows players to add friends and see when they're online.
/// Buddy list changes are stored in the BuddyListRegistry and updated in real-time.
///
/// # Operations
///
/// ## Add Buddy
/// - Request to add a character by name
/// - Server searches for character in the same world
/// - If found, adds to player's buddy list
/// - If already in list, sends error message
/// - If not found, sends "Character not found" error
///
/// ## Accept Buddy Request
/// - Accepts a pending buddy request
/// - Adds the requesting player to buddy list
/// - Both players become mutual buddies
///
/// ## Remove Buddy
/// - Removes a character from buddy list
/// - Takes effect immediately
/// - Buddy list is updated and sent to client
///
/// # Buddy List Limitations
///
/// - Buddy list has a maximum capacity (typically 20-30 slots)
/// - Cannot add yourself as a buddy
/// - Can only add characters in the same world
/// - Character must exist to be added
///
/// # Response
///
/// After any modification, sends `BuddyListNotification.update` with:
/// - Complete updated buddy list
/// - Online status of each buddy
/// - Channel of each online buddy
/// - -1 if buddy is offline
///
/// # Error Messages
///
/// | Situation | Message |
/// |-----------|---------|
/// | Character not found | "Character not found." |
/// | Already in buddy list | "[Name] is already in your buddy list." |
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
