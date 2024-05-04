//
//  SessionEncryptionHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation
import MapleStory28
import MapleStoryServer
import CoreModel

public struct SessionEncryptionHandler <Socket: MapleStorySocket, Database: ModelStorage>: ServerHandler {
    
    public typealias Connection = MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
        
    public let channel: Channel.ID
    
    public init(channel: Channel.ID) {
        self.channel = channel
    }
    
    public func didConnect(
        connection: Connection
    ) async throws {
        try await connection.startSession(for: channel)
    }
    
    public func didDisconnect(
        address: MapleStoryAddress,
        server: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>
    ) async throws {
        let ipAddress = address.address
        let database = server.database
        guard let session = try await Session.fetch(address: ipAddress, channel: channel, in: database) else {
            throw MapleStoryError.notAuthenticated
        }
        try await server.close(session: session)
    }
}
