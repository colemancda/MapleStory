//
//  DeleteCharacterHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct DeleteCharacterHandler: PacketHandler {
        
    public typealias Packet = MapleStory83.DeleteCharacterRequest
    
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
        _ request: MapleStory83.DeleteCharacterRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory83.DeleteCharacterResponse {
        try await connection.deleteCharacter(request.character, picCode: request.picCode)
        return .init(character: request.character, state: 0x00)
    }
}
