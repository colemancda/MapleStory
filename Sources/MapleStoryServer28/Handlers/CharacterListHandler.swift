//
//  CharacterListHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import CoreModel
import MapleStory28
import MapleStoryServer
/*
public struct CharacterListHandler: PacketHandler {
    
    public typealias Packet = MapleStory28.CharacterListRequest
        
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
        _ request: MapleStory28.CharacterListRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory28.CharacterListResponse {
        let characters = try await connection.characterList(
            world: request.world,
            channel: request.channel
        )
        return CharacterListResponse(
            characters: characters.map { .init($0) }
        )
    }
}
*/
