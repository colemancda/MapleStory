//
//  AllCharactersListHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct AllCharactersListHandler: PacketHandler {
    
    public typealias Packet = MapleStory83.AllCharactersRequest
        
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
    ) async throws -> [MapleStory83.AllCharactersResponse] {
        let limit = 60
        let charactersByWorld = try await connection.characterList()
        guard charactersByWorld.isEmpty == false else {
            return [.count(status: .notFound, worlds: 0, characters: 0)]
        }
        let charactersCount = charactersByWorld.reduce(into: 0, { $0 += $1.characters.count })
        let countResponse = AllCharactersResponse.count(
            status: .foundCharacters,
            worlds: UInt32(charactersByWorld.count),
            characters: UInt32(charactersCount)
        )
        return [countResponse] + charactersByWorld.map {
            .characters(
                world: $0.world,
                characters: $0.characters.prefix(limit).map { .init($0) },
                picMode: .disabled
            )
        }
    }
}
