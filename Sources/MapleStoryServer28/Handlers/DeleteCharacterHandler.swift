//
//  DeleteCharacterHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import CoreModel
import MapleStory28
import MapleStoryServer

public struct DeleteCharacterHandler: PacketHandler {
        
    public typealias Packet = MapleStory28.DeleteCharacterRequest
    
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
        _ request: MapleStory28.DeleteCharacterRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory28.DeleteCharacterResponse {
        do {
            try await connection.deleteCharacter(request.character)
            return .init(character: request.character)
        }
        catch MapleStoryError.invalidBirthday {
            return .init(character: request.character, error: .invalidDateOfBirth)
        }
        catch {
            return .init(character: request.character, error: .serverLoadError)
        }
    }
}
