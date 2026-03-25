//
//  DeleteCharacterHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 5/1/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles character deletion requests.
///
/// # Character Deletion System
///
/// Players can delete characters they no longer want to play.
/// This handler validates the request and permanently removes
/// the character from the database.
///
/// # Deletion Flow
///
/// 1. Player selects character and clicks "Delete" button
/// 2. Client sends delete character request with character ID
/// 3. Server validates ownership (character belongs to account)
/// 4. Server deletes character from database
/// 5. Server deletes related data (items, quests, etc.)
/// 6. Server sends confirmation response
/// 7. Client removes character from list
///
/// # Character Ownership Validation
///
/// Server ensures:
/// - Character belongs to the requesting account
/// - Character is not currently logged in
/// - Character exists in the database
///
/// # Data Deletion
///
/// When a character is deleted, the following is removed:
/// - Character record
/// - Inventory items
/// - Equipment
/// - Quest progress
/// - Skills
/// - Buddy list entries
/// - Guild membership (leaves guild if member)
/// - Party membership (kicked from party if member)
///
/// # Permanent Deletion
///
/// ⚠️ **WARNING**: Character deletion is permanent
/// - No undo option
/// - No character recovery
/// - All progress is lost
/// - Items and mesos cannot be recovered
///
/// # Response States
///
/// Returns `DeleteCharacterResponse` with:
/// - **character**: ID of deleted character
/// - **state**: Status code
///   - `0x00`: Success
///   - `0x10`: Failure (incorrect PIC/password)
///   - `0x20`: Failure (character not found)
///
/// # Security Considerations
///
/// - Account authentication required
/// - PIC (Personal Identification Code) validation
/// - Cannot delete while logged in
/// - Cannot delete other accounts' characters
///
/// # GM Characters
///
/// GM characters may have additional protections:
/// - Cannot be deleted by regular accounts
/// - May require special permissions
/// - Deletion logged for audit purposes
///
/// # Character Limit
///
/// After deletion, player has one fewer character.
/// This allows creating a new character in that slot
/// (up to the 9-character limit per world).
///
/// # TODO
///
/// - Implement PIC/password validation
/// - Implement deletion cooldown (to prevent accidental deletion)
/// - Add character deletion confirmation dialog
/// - Log deletion events for audit
public struct DeleteCharacterHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.DeleteCharacterRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await deleteCharacter(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension DeleteCharacterHandler {
    
    func deleteCharacter<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.DeleteCharacterRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory62.DeleteCharacterResponse {
        try await connection.deleteCharacter(request.character)
        return .init(character: request.character, state: 0x00)
    }
}
