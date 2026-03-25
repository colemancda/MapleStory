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
/// - Checks if player's buddy list is full (error 11)
/// - Checks if target's buddy list is full (error 12)
/// - Checks if already on list (error 13)
/// - If not found, sends error 15
/// - If successful, sends buddy request notification to target
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
/// - Buddy list has a maximum capacity (default: 25)
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
        let isFull = await BuddyListRegistry.shared.isFull(character.id, capacity: character.buddyCapacity)
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
        let alreadyInList = await BuddyListRegistry.shared.contains(buddyID: otherCharacter.index, in: character.id)
        if alreadyInList {
            try await connection.send(BuddyListMessageNotification.alreadyOnList)
            return
        }
        
        // Check if target's buddy list is full (error 12)
        let targetIsFull = await BuddyListRegistry.shared.isFull(otherCharacter.id, capacity: otherCharacter.buddyCapacity)
        if targetIsFull {
            try await connection.send(BuddyListMessageNotification.otherBuddyListFull)
            return
        }
        
        // Add pending request for the target
        _ = await BuddyListRegistry.shared.addPendingRequest(
            from: character.index,
            fromName: character.name,
            to: otherCharacter.id
        )
        
        // Send buddy request notification to the target character
        // Note: In a full implementation, this would be sent to the target's active connection
        // via cross-channel messaging. For now, we just queue the pending request.
        
        // Also add to sender's buddy list (as pending/invisible until accepted)
        // In Java implementation, this is done differently - the sender sees the buddy
        // but with a "pending" status. For simplicity, we'll just notify the sender.
        
        // Send updated buddy list to the player
        let list = await BuddyListRegistry.shared.list(for: character.id)
        try await connection.send(BuddyListNotification.update(list))
    }
    
    // MARK: - Accept Buddy
    
    private func handleAcceptBuddy<Socket: MapleStorySocket, Database: ModelStorage>(
        characterID: UInt32,
        character: Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Check if player's buddy list is full
        let isFull = await BuddyListRegistry.shared.isFull(character.id, capacity: character.buddyCapacity)
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
        
        // Check if there's a pending request from this character
        let hasPendingRequest = await BuddyListRegistry.shared.hasPendingRequest(
            from: characterID,
            to: character.id
        )
        
        // Add to accepter's buddy list
        let added = await BuddyListRegistry.shared.add(
            BuddyListNotification.Buddy(
                id: otherCharacter.index,
                name: otherCharacter.name,
                value0: 0,
                channel: -1
            ),
            to: character.id
        )
        
        guard added else {
            // Already in list
            try await connection.send(BuddyListMessageNotification.alreadyOnList)
            return
        }
        
        // Remove the pending request if it existed
        if hasPendingRequest {
            _ = await BuddyListRegistry.shared.removePendingRequest(from: characterID, to: character.id)
        }
        
        // Also add accepter to requester's buddy list (mutual buddies)
        _ = await BuddyListRegistry.shared.add(
            BuddyListNotification.Buddy(
                id: character.index,
                name: character.name,
                value0: 0,
                channel: -1
            ),
            to: otherCharacter.id
        )
        
        // Send updated buddy list to the player
        let list = await BuddyListRegistry.shared.list(for: character.id)
        try await connection.send(BuddyListNotification.update(list))
    }
    
    // MARK: - Remove Buddy
    
    private func handleRemoveBuddy<Socket: MapleStorySocket, Database: ModelStorage>(
        characterID: UInt32,
        character: Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Remove from player's buddy list
        let removed = await BuddyListRegistry.shared.remove(buddyID: characterID, from: character.id)
        
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
            _ = await BuddyListRegistry.shared.remove(buddyID: character.index, from: otherCharacter.id)
        }
        
        // Send updated buddy list to the player
        let list = await BuddyListRegistry.shared.list(for: character.id)
        try await connection.send(BuddyListNotification.update(list))
    }
}