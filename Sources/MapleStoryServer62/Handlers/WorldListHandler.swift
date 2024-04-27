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

public extension MapleStoryServer {
    
    /// MapleStory v62 World List Server handler
    struct WorldListHandler: PacketHandler {
                
        public let connection: MapleStoryServer<Socket, Storage>.Connection
        
        public init(connection: MapleStoryServer<Socket, Storage>.Connection) {
            self.connection = connection
        }
        
        public func handle(packet request: MapleStory62.ServerListRequest) async throws {
            do {
                let responses = try await worldList(request)
                for response in responses {
                    try await connection.respond(response)
                }
            }
            catch {
                await connection.close(error)
            }
        }
    }
}

internal extension MapleStoryServer.WorldListHandler {
    
    func worldList(
        _ request: MapleStory62.ServerListRequest
    ) async throws -> [MapleStory62.ServerListResponse] {
        try await connection.listWorlds()
            .map { .world(.init(world: $0.world, channels: $0.channels)) } + [.end]
    }
}
