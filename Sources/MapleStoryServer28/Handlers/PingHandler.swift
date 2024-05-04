//
//  PingHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import MapleStory28
import MapleStoryServer
import CoreModel

public struct PingHandler <Socket: MapleStorySocket, Database: ModelStorage>: ServerHandler {
    
    public typealias Connection = MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    
    public init() { }
    
    public func didConnect(
        connection: Connection
    ) async {
        let pingInterval = 15
        Task { [weak connection] in
            while let connection {
                try await Task.sleep(for: .seconds(pingInterval), clock: .continuous)
                //try await connection.send(PingPacket())
            }
        }
    }
    
    public func didDisconnect(address: MapleStoryAddress) async {
        
    }
}
