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
        let characters = try await connection.characterList()
        return []
        //return [.count(characters.count)] + characters.map { }
    }
}
