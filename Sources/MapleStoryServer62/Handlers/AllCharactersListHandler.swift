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

public struct AllCharactersListHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.AllCharactersRequest
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws {
        let responses = try await characterList(packet, connection: connection)
        for response in responses {
            try await connection.respond(response)
        }
    }
}

internal extension AllCharactersListHandler {
    
    func characterList<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
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
