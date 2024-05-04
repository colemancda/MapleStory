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
