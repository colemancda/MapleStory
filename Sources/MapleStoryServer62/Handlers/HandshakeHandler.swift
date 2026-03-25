//
//  HandshakeHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/27/24.
//

import Foundation
import MapleStory62
import MapleStoryServer
import CoreModel

/// Handles the initial connection handshake with newly connected clients.
///
/// When a client connects, the server must send a `HelloPacket` containing
/// the cryptographic nonces used to encrypt the connection. This is the
/// first packet sent after a TCP connection is established.
///
/// # Handshake Flow
///
/// 1. Client establishes TCP connection
/// 2. Server sends HelloPacket with send/receive nonces and region
/// 3. Client and server both initialize their AES encryption using the nonces
/// 4. All subsequent packets are encrypted
///
/// # HelloPacket Contents
///
/// - **recvNonce**: Nonce used to decrypt packets from client
/// - **sendNonce**: Nonce used to encrypt packets to client
/// - **region**: Server region (affects some gameplay behaviors)
///
/// # Disconnection Handling
///
/// When a client disconnects, the handler looks up their session by IP
/// address and channel, then closes the session to clean up server state.
///
/// # Channel Association
///
/// The `channel` property identifies which channel this connection is for.
/// Login server connections have `channel = nil`.
/// Channel server connections have a specific channel ID.
public struct HandshakeHandler <Socket: MapleStorySocket, Database: ModelStorage>: ServerHandler {
    
    public let channel: Channel.ID?
    
    public init(channel: Channel.ID? = nil) {
        self.channel = channel
    }
    
    public func didConnect(
        connection: MapleStoryServer<Socket, Database, MapleStory62.ClientOpcode, MapleStory62.ServerOpcode>.Connection
    ) async throws {
        try await self.sendHandshake(connection: connection)
    }
    
    public func didDisconnect(address: MapleStory.MapleStoryAddress, server: MapleStoryServer<Socket, Database, MapleStory62.ClientOpcode, MapleStory62.ServerOpcode>) async throws {
        // fetch session from IP address
        let ipAddress = address.address
        if let channel, let session = try await Session.fetch(address: ipAddress, channel: channel, in: server.database) {
            try await server.close(session: session)
        }
    }
}

internal extension HandshakeHandler {
    
    func sendHandshake(
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    )  async throws {
        let encoder = MapleStoryEncoder()
        let packet = await MapleStory62.HelloPacket(
            recieveNonce: connection.recieveNonce,
            sendNonce: connection.sendNonce,
            region: connection.region
        )
        let data = try encoder.encode(packet)
        try await connection.send(data)
        await connection.encrypt()
    }
}
