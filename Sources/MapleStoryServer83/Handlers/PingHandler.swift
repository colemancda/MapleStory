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

public struct PingHandler: PacketHandler {
    
    public typealias Packet = PongPacket
    
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
