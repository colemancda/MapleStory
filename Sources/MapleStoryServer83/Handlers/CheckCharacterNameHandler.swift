//
//  CheckCharacterNameHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct CheckCharacterNameHandler: PacketHandler {
    
    public typealias Packet = MapleStory83.CheckNameRequest
        
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws {
        let response = try await checkCharacterName(packet, connection: connection)
        try await connection.respond(response)
    }
}

internal extension CheckCharacterNameHandler {
    
    func checkCharacterName<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory83.CheckNameRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws -> MapleStory83.CheckNameResponse {
        let isAvailable = try await connection.checkCharacterName(request.name)
        return .init(name: request.name, isUsed: !isAvailable)
    }
}
