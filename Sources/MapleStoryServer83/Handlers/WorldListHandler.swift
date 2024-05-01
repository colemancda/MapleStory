//
//  WorldListHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import CoreModel
import MapleStory83
import MapleStoryServer

/// MapleStory v83 World List Server handler
public struct WorldListHandler: PacketHandler {
    
    public typealias Packet = MapleStory83.ServerListRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws {
        do {
            // update IP address
            guard var user = try await connection.user else {
                throw MapleStoryError.notAuthenticated
            }
            user.ipAddress = connection.address.address
            try await connection.database.insert(user)
            // return world list responses
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
        _ request: MapleStory83.ServerListRequest,
        connection: MapleStoryServer<Socket, Database>.Connection
    ) async throws -> [MapleStory83.ServerListResponse] {
        try await connection.listWorlds()
            .map { .world(.init(world: $0.world, channels: $0.channels)) } + [.end]
    }
}
