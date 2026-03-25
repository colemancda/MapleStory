//
//  PingHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import MapleStory62
import MapleStoryServer
import CoreModel

/// Handles keepalive ping/pong packets to maintain the connection.
///
/// MapleStory uses a ping/pong mechanism to keep connections alive and
/// detect disconnected clients. The server sends a Ping, the client
/// responds with a Pong. This handler processes the Pong response and
/// schedules the next Ping.
///
/// # Ping/Pong Flow
///
/// 1. Server sends `PingPacket` to client
/// 2. Client responds with `PongPacket`
/// 3. Server receives Pong → schedules next Ping after 15 seconds
/// 4. If no Pong received within timeout → client is disconnected
///
/// # Timing
///
/// - Ping interval: 15 seconds
/// - Connection timeout: If no pong received for 30 seconds, disconnect
///
/// # TODO
///
/// - Update connection timestamp to prevent timeout disconnection
/// - Track last pong time for timeout detection
public struct PingHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.PongPacket
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // TODO: Update connection timeout
        let response = PingPacket()
        Task {
            try await Task.sleep(for: .seconds(15))
            try await connection.send(response)
        }
    }
}
