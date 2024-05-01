//
//  ServerStatusHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

public struct ServerStatusHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.ServerStatusRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet request: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws {
        let response = try await serverStatus(request, connection: connection)
        try await connection.respond(response)
    }
}

internal extension ServerStatusHandler {
    
    func serverStatus<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.ServerStatusRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws -> MapleStory62.ServerStatusResponse {
        let status = try await connection.serverStatus(
            world: request.world,
            channel: request.channel
        )
        return .init(status)
    }
}
