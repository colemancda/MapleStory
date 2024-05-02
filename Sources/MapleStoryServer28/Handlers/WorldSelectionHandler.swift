//
//  WorldSelectionHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import CoreModel
import MapleStory28
import MapleStoryServer

public struct WorldSelectionHandler: PacketHandler {
    
    public typealias Packet = MapleStory28.WorldSelectionRequest
    
    public init() { }
    
    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let response = try await selectWorld(packet, connection: connection)
        try await connection.send(response)
    }
}

internal extension WorldSelectionHandler {
    
    func selectWorld<Socket: MapleStorySocket, Database: ModelStorage>(
        _ request: MapleStory28.WorldSelectionRequest,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws -> MapleStory28.WorldMetadataResponse {
        let (warning, population) = try await connection.selectWorld(request.world)
        return .init(warning: warning, population: population)
    }
}
