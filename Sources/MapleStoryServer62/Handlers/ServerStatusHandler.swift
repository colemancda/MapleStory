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

/// Handles requests for server/channel status information.
///
/// The client queries server status to determine if a channel is available,
/// at normal load, or full. This is displayed in the channel selection screen.
///
/// # Server Status Values
///
/// - **Normal** (0): Server has available capacity
/// - **HighLoad** (1): Server is experiencing high player counts
/// - **Full** (2): Server is at capacity, new logins may be blocked
///
/// # Flow
///
/// 1. Client sends status request for a specific world/channel
/// 2. Server looks up current player count vs. capacity
/// 3. Server returns appropriate status code
/// 4. Client displays the status in the UI
///
/// # Response
///
/// Returns `ServerStatusResponse` with the channel's current load status.
public struct ServerStatusHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.ServerStatusRequest
    
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
        _ request: MapleStory62.ServerStatusRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory62.ServerStatusResponse {
        let status = try await connection.serverStatus(
            world: request.world,
            channel: request.channel
        )
        return .init(status)
    }
}
