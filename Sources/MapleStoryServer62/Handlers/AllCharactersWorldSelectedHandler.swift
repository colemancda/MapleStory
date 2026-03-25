//
//  AllCharactersWorldSelectedHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/4/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// Handles world selection in the "all characters" view.
///
/// When a player selects a specific world from the all-characters list,
/// the server responds with character counts and character data for that world.
/// This is used when the client is in "all servers" mode showing characters
/// across all worlds.
///
/// # Response
///
/// Sends one or more `AllCharactersResponse` packets:
/// 1. A count packet indicating total characters across worlds
/// 2. One character list packet per world with characters
///
/// If the account has no characters, returns a single count packet with 0 characters.
///
/// # Character Limit
///
/// Up to 60 characters are returned per world (first 60 if more exist).
public struct AllCharactersWorldSelectedHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.AllCharactersWorldSelectedRequest
    
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

internal extension AllCharactersWorldSelectedHandler {
    
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

