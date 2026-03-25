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
/// Buddy relationships are persisted in the database using the `Buddy` entity.
///
/// # Operations
///
/// ## Add Buddy
/// - Request to add a character by name
/// - Server searches for character in the same world
/// - Checks if player's buddy list is full (error 11)
/// - Checks if target's buddy list is full (error 12)
/// - Checks if already on list (error 13)
/// - If not found, sends error 15
/// - If successful, sends buddy request notification to target
///
/// ## Accept Buddy Request
/// - Accepts a pending buddy request
/// - Adds the requesting player to buddy list (persisted to DB)
/// - Both players become mutual buddies
///
/// ## Remove Buddy
/// - Removes a character from buddy list
/// - Deleted from database immediately
/// - Buddy list is updated and sent to client
///
/// # Error Codes (BuddyListMessageNotification)
///
/// | Code | Situation |
/// |------|-----------|
/// | 11   | Your buddy list is full |
/// | 12   | Other person's buddy list is full |
/// | 13   | Already on buddy list (hidden) |
/// | 15   | Character not found |
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
            try await handleAddBuddy(name: name, character: character, connection: connection)

        case .accept(let characterID):
            try await handleAcceptBuddy(characterID: characterID, character: character, connection: connection)

        case .remove(let characterID):
            try await handleRemoveBuddy(characterID: characterID, character: character, connection: connection)
        }
    }
    
    // MARK: - Add Buddy
    
    private func handleAddBuddy<Socket: MapleStorySocket, Database: ModelStorage>(
        name: String,
        character: Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let characterName = CharacterName(rawValue: name) else {
            // Invalid name format - send character not found error
            try await connection.send(BuddyListMessageNotification.characterNotFound)
            return
        }
        
        // Check if player's buddy list is full (error 11)
        let isFull = try await BuddyListRegistry.shared.isFull(
            character.id,
            capacity: character.buddyCapacity,
            in: connection.database
        )
        if isFull {
            try await connection.send(BuddyListMessageNotification.buddyListFull)
            return
        }
        
        // Find the target character in the same world
        let predicates: [Character.Predicate] = [
            .name(characterName),
            .world(character.world)
        ]
        let predicate = FetchRequest.Predicate.compound(.and(predicates.map { .init(predicate: $0) }))
        
        guard let otherCharacter = try await connection.database.fetch(Character.self, predicate: predicate, fetchLimit: 1).first,
              otherCharacter.id != character.id else {
            // Character not found (error 15)
            try await connection.send(BuddyListMessageNotification.characterNotFound)
            return
        }
        
        // Check if already in buddy list (error 13 - hidden)
        let alreadyInList = try await BuddyListRegistry.shared.contains(
            buddyID: otherCharacter.index,
            in: character.id,
            database: connection.database
        )
        if alreadyInList {
            try await connection.send(BuddyListMessageNotification.alreadyOnList)
            return
        }
        
        // Check if target's buddy list is full (error 12)
        let targetIsFull = try await BuddyListRegistry.shared.isFull(
            otherCharacter.id,
            capacity: otherCharacter.buddyCapacity,
            in: connection.database
        )
        if targetIsFull {
            try await connection.send(BuddyListMessageNotification.otherBuddyListFull)
            return
        }
        
        // Add pending buddy entry for sender (pending = true)
        let senderBuddy = Buddy(
            character: character.id,
            buddyID: otherCharacter.index,
            pending: true
        )
        _ = try await BuddyListRegistry.shared.addBuddy(
            senderBuddy,
            to: character.id,
            in: connection.database
        )
        
        // Add pending buddy entry for target (pending = true)
        let targetBuddy = Buddy(
            character: otherCharacter.id,
            buddyID: character.index,
            pending: true
        )
        _ = try await BuddyListRegistry.shared.addBuddy(
            targetBuddy,
            to: otherCharacter.id,
            in: connection.database
        )
        
        // Add in-memory pending request notification for target
        _ = await BuddyListRegistry.shared.addPendingRequest(
            from: character.index,
            fromName: character.name,
            to: otherCharacter.id
        )
        
        // Send updated buddy list to the player
        let list = try await BuddyListRegistry.shared.buddyListNotification(
            for: character.id,
            in: connection.database
        )
        try await connection.send(BuddyListNotification.update(list))
    }
    
    // MARK: - Accept Buddy
    
    private func handleAcceptBuddy<Socket: MapleStorySocket, Database: ModelStorage>(
        characterID: UInt32,
        character: Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Check if player's buddy list is full
        let isFull = try await BuddyListRegistry.shared.isFull(
            character.id,
            capacity: character.buddyCapacity,
            in: connection.database
        )
        if isFull {
            try await connection.send(BuddyListMessageNotification.buddyListFull)
            return
        }
        
        // Find the character who sent the request
        guard let otherCharacter = try await Character.fetch(
            characterID,
            world: character.world,
            in: connection.database
        ),
              otherCharacter.id != character.id else {
            return
        }
        
        // Update accepter's buddy entry to non-pending
        let updated = try await BuddyListRegistry.shared.updateBuddyPending(
            buddyID: characterID,
            for: character.id,
            pending: false,
            in: connection.database
        )
        
        guard updated else {
            // Not in list or error
            return
        }
        
        // Update requester's buddy entry to non-pending (mutual)
        _ = try await BuddyListRegistry.shared.updateBuddyPending(
            buddyID: character.index,
            for: otherCharacter.id,
            pending: false,
            in: connection.database
        )
        
        // Remove the in-memory pending request
        _ = await BuddyListRegistry.shared.removePendingRequest(
            from: characterID,
            to: character.id
        )
        
        // Send updated buddy list to the player
        let list = try await BuddyListRegistry.shared.buddyListNotification(
            for: character.id,
            in: connection.database
        )
        try await connection.send(BuddyListNotification.update(list))
    }
    
    // MARK: - Remove Buddy
    
    private func handleRemoveBuddy<Socket: MapleStorySocket, Database: ModelStorage>(
        characterID: UInt32,
        character: Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Remove from player's buddy list (from database)
        let removed = try await BuddyListRegistry.shared.removeBuddy(
            buddyID: characterID,
            from: character.id,
            in: connection.database
        )
        
        guard removed else {
            // Not in list, nothing to do
            return
        }
        
        // Also remove player from the other character's buddy list (mutual removal)
        // Find the other character to get their UUID
        if let otherCharacter = try await Character.fetch(
            characterID,
            world: character.world,
            in: connection.database
        ) {
            _ = try await BuddyListRegistry.shared.removeBuddy(
                buddyID: character.index,
                from: otherCharacter.id,
                in: connection.database
            )
        }
        
        // Send updated buddy list to the player
        let list = try await BuddyListRegistry.shared.buddyListNotification(
            for: character.id,
            in: connection.database
        )
        try await connection.send(BuddyListNotification.update(list))
    }
}