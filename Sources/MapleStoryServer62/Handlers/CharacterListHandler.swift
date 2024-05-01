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

public struct CharacterListHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.CharacterListRequest
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws {
        let response = try await characterList(packet, connection: connection)
        try await connection.respond(response)
    }
}

internal extension CharacterListHandler {
    
    func characterList<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.CharacterListRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
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
