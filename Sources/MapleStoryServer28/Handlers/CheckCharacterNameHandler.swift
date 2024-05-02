//
//  CheckCharacterNameHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import CoreModel
import MapleStory28
import MapleStoryServer

public struct CheckCharacterNameHandler: PacketHandler {
    
    public typealias Packet = MapleStory28.CheckCharacterNameRequest
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await checkCharacterName(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension CheckCharacterNameHandler {
    
    func checkCharacterName<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory28.CheckCharacterNameRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory28.CheckCharacterNameResponse {
        let isAvailable = try await connection.checkCharacterName(request.name)
        return .init(name: request.name, isUsed: !isAvailable)
    }
}
