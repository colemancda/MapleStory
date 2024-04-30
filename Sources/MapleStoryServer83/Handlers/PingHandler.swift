//
//  PingHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import MapleStory83
import MapleStoryServer
import CoreModel

public struct PingHandler: ServerHandler {
    
    public init() { }
    
    public func didConnect<Socket, Storage>(
        connection: MapleStoryServer<Socket, Storage>.Connection
    ) where Socket : MapleStorySocket, Storage : ModelStorage {
        let pingInterval = 15
        Task { [weak connection] in
            while let connection {
                try await Task.sleep(for: .seconds(pingInterval), clock: .continuous)
                try await connection.send(PingPacket())
            }
        }
    }
}
