//
//  SelectCharacterHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation
import CoreModel
import MapleStory28
import MapleStoryServer

public struct SelectCharacterHandler: PacketHandler {
        
    public typealias Packet = MapleStory28.CharacterSelectRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await selectCharacter(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension SelectCharacterHandler {
    
    func selectCharacter<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory28.CharacterSelectRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory28.ServerIPResponse {
        let address = try await connection.selectCharacter(request.character)
        return .init(address: address, character: request.character)
    }
}
