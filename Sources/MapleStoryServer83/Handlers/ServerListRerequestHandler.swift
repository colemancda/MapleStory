//
//  ServerListRerequestHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/4/24.
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

/// MapleStory v83 World List Server handler
public struct ServerListRerequestHandler: PacketHandler {
    
    public typealias Packet = MapleStory83.ServerListRerequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        do {
            // world list
            let responses = try await worldList(packet, connection: connection)
            for response in responses {
                try await connection.send(response)
            }
        }
        catch {
            await connection.close(error)
        }
    }
}

internal extension ServerListRerequestHandler {
    
    func worldList<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory83.ServerListRerequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> [MapleStory83.ServerListResponse] {
        try await connection.listWorlds()
            .map { .world($0.world, channels: $0.channels) } + [.end]
    }
}
