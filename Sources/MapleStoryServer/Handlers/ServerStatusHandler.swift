//
//  ServerStatusHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory
import CoreModel

public extension MapleStoryServer.Connection {
    
    func serverStatus(
        world worldIndex: World.Index,
        channel channelIndex: Channel.Index
    ) async throws -> Channel.Status {
        log("Server Status - World \(worldIndex) Channel \(channelIndex)")
        guard let world = try await World.fetch(
            index: worldIndex,
            version: version,
            region: region,
            in: database
        ) else {
            throw MapleStoryError.invalidRequest
        }
        guard let channel = try await Channel.fetch(channelIndex, world: world.id, in: database) else {
            throw MapleStoryError.invalidRequest
        }
        return channel.status
    }
}
