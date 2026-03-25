//
//  CheckCharacterNameHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles requests to check if a character name is available.
///
/// # Character Name Validation
///
/// Before creating a new character, players must choose a unique name.
/// This handler checks if the requested name is available for use.
///
/// # Name Check Flow
///
/// 1. Player types character name in create character screen
/// 2. Client sends name check request
/// 3. Server checks if name exists in database
/// 4. Server returns availability status
/// 5. Client enables/disables "Create" button based on result
///
/// # Name Validation Rules
///
/// Character names must:
/// - Be unique (no duplicates across entire world)
/// - Follow naming conventions (length, characters, etc.)
/// - Not contain prohibited words
/// - Not be a reserved name
///
/// # Response Values
///
/// Returns `CheckCharacterNameResponse` with:
/// - **name**: The requested character name
/// - **isUsed**: true if name is taken, false if available
///
/// Note: The field is named `isUsed` (inverse of availability)
///
/// # Client Behavior
///
/// - **Name available**: Client enables "Create" button
/// - **Name taken**: Client shows "Name already in use" message
/// - **Invalid name**: Client shows name requirements
///
/// # Name Uniqueness
///
/// - Names are unique per world, not per account
/// - Same name can exist in different worlds (e.g., Scania and Bera)
/// - Case-sensitive: "PlayerName" ≠ "playername"
///
/// # Reserved Names
///
/// The following names are typically reserved:
/// - GM names (e.g., "GM", "Administrator")
/// - Staff names
/// - Character class names
/// - System names
public struct CheckCharacterNameHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.CheckCharacterNameRequest
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await checkCharacterName(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension CheckCharacterNameHandler {
    
    func checkCharacterName<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.CheckCharacterNameRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory62.CheckCharacterNameResponse {
        let isAvailable = try await connection.checkCharacterName(request.name)
        return .init(name: request.name, isUsed: !isAvailable)
    }
}
