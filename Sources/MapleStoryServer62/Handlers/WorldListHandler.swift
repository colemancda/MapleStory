//
//  WorldListHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import CoreModel
import MapleStory62
import MapleStoryServer

/// MapleStory v62 World List Server handler
public struct WorldListHandler: PacketHandler {
    
    public typealias Packet = MapleStory62.ServerListRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws {
        do {
            let responses = try await worldList(packet, connection: connection)
            for response in responses {
                try await connection.respond(response)
            }
        }
        catch {
            await connection.close(error)
        }
    }
}

internal extension WorldListHandler {
    
    func worldList<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory62.ServerListRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws -> [MapleStory62.ServerListResponse] {
        try await connection.listWorlds()
            .map { .world(.init(world: $0.world, channels: $0.channels)) } + [.end]
    }
}
