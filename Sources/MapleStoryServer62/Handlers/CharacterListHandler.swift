//
//  CharacterListHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles requests for the character list for a specific world and channel.
///
/// # Character List System
///
/// After logging in and selecting a world, players see a list of their
/// characters for that world. This handler returns the character list
/// for the requested world and channel combination.
///
/// # Character List Flow
///
/// 1. Player logs in and selects a world
/// 2. Client sends character list request with world and channel
/// 3. Server fetches all characters for that account and world
/// 4. Server returns character list with character details
/// 5. Client displays character selection screen
///
/// # Character List Content
///
/// Each character in the list includes:
/// - Character name
/// - Level and job
/// - Face, hair, and skin color
/// - Equipment (displayed on character)
/// - Current map
/// - Guild (if in one)
///
/// # Character Limit
///
/// Maximum characters per world: 9
///
/// # Character Slots
///
/// Players can have up to 9 characters per world. Additional slots
/// can be purchased from the Cash Shop (not implemented yet).
///
/// # World-Specific Characters
///
/// Characters are tied to specific worlds:
/// - Scania characters only appear in Scania
/// - Bera characters only appear in Bera
/// - Cannot transfer characters between worlds
///
/// # Response
///
/// Returns `CharacterListResponse` with:
/// - Array of character data
/// - Maximum character slots (9)
///
/// # Empty Account
///
/// If the account has no characters:
/// - Returns empty character list
/// - Client shows "Create Character" option
public struct CharacterListHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.CharacterListRequest
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await characterList(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension CharacterListHandler {
    
    func characterList<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.CharacterListRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory62.CharacterListResponse {
        let characters = try await connection.characterList(
            world: request.world,
            channel: request.channel
        )
        return CharacterListResponse(
            characters: characters.map { .init($0) },
            maxCharacters: 9
        )
    }
}
