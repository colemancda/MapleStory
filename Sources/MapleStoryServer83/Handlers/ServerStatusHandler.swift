//
//  ServerStatusHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

public struct ServerStatusHandler: PacketHandler {
    
    public typealias Packet = MapleStory83.ServerStatusRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet request: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await serverStatus(request, connection: connection)
        try await connection.send(response)
    }
}

internal extension ServerStatusHandler {
    
    func serverStatus<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory83.ServerStatusRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory83.ServerStatusResponse {
        let status = try await connection.serverStatus(
            world: request.world,
            channel: request.channel
        )
        return .init(status)
    }
}
