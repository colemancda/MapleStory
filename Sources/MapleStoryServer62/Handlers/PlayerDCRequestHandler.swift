//
//  PlayerDCRequestHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/4/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// MapleStory v62 World List Server handler
public struct PlayerDCRequestHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.PlayerDCRequest
    
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

internal extension PlayerDCRequestHandler {
    
    func worldList<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.PlayerDCRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> [MapleStory62.ServerListResponse] {
        try await connection.listWorlds()
            .map { .world(.init(world: $0.world, channels: $0.channels)) } + [.end]
    }
}
