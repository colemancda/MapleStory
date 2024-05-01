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

public struct DeleteCharacterHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.DeleteCharacterRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws {
        let response = try await deleteCharacter(packet, connection: connection)
        try await connection.respond(response)
    }
}

internal extension DeleteCharacterHandler {
    
    func deleteCharacter<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.DeleteCharacterRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws -> MapleStory62.DeleteCharacterResponse {
        try await connection.deleteCharacter(request.character)
        return .init(character: request.character, state: 0x00)
    }
}
