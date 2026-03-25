//
//  AllCharactersListHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles requests to list all characters across all worlds.
///
/// # Character List Flow
///
/// 1. Client requests all characters for logged-in account
/// 2. Server fetches characters grouped by world
/// 3. Server limits to 60 characters per world
/// 4. Server sends character count packet
/// 5. Server sends character list packets (one per world)
///
/// # Response Structure
///
/// The server sends multiple packets:
/// - First packet: Total character count
/// - Subsequent packets: Characters per world (max 60 per world)
///
/// # Empty Account
///
/// If the account has no characters:
/// - Returns single packet with count = 0, value0 = 3
///
/// # Purpose
///
/// This handler is used to display the character selection screen showing
/// all characters the account has created across all worlds.
public struct AllCharactersListHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.AllCharactersRequest
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let responses = try await characterList(packet, connection: connection)
        for response in responses {
            try await connection.send(response)
        }
    }
}

internal extension AllCharactersListHandler {
    
    func characterList<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> [MapleStory62.AllCharactersResponse] {
        let limit = 60
        let charactersByWorld = try await connection.characterList()
        guard charactersByWorld.isEmpty == false else {
            return [.count(characters: 0, value0: 3)]
        }
        let charactersCount = charactersByWorld.reduce(into: 0, { $0 += $1.characters.count })
        return [.count(charactersCount)] + charactersByWorld.map {
            .characters(
                world: $0.world,
                characters: $0.characters.prefix(limit).map { .init($0) }
            )
        }
    }
}
