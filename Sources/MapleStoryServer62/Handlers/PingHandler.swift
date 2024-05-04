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

public struct PingHandler<Socket: MapleStorySocket, Database: ModelStorage>: ServerHandler {
    
    public init() { }
    
    public func didConnect(
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) {
        let pingInterval = 15
        Task { [weak connection] in
            while let connection {
                try await Task.sleep(for: .seconds(pingInterval), clock: .continuous)
                try await connection.send(PingPacket())
            }
        }
    }
    
    public func didDisconnect(address: MapleStory.MapleStoryAddress, server: MapleStoryServer<Socket, Database, MapleStory62.ClientOpcode, MapleStory62.ServerOpcode>) async throws {
        
        
    }
}
