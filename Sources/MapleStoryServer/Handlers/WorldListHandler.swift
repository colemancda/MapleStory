//
//  WorldListHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import CoreModel
import MapleStory

public extension MapleStoryServer.Connection {
    
    /// Handle a user logging in.
    func listWorlds() async throws -> [(world: World, channels: [Channel])] {
        log("World List")
        let database = server.dataSource.storage
        let version = await self.connection.version
        let region = await self.connection.region
        // fetch worlds
        var worlds = try await World.fetch(
            version: version,
            region: region,
            in: database
        )
        // lazily create worlds if none
        if worlds.isEmpty {
            // TODO: Global syncronized task
            worlds = try await World.insert(
                region: region,
                version: version,
                in: database
            )
        }
        // fetch channels
        var results = [(world: World, channels: [Channel])]()
        results.reserveCapacity(worlds.count)
        for world in worlds {
            var channels = [Channel]()
            channels.reserveCapacity(world.channels.count)
            for channelID in world.channels {
                // TODO: Optimize
                guard let channel = try await database.fetch(Channel.self, for: channelID) else {
                    assertionFailure()
                    continue
                }
                channels.append(channel)
            }
            results.append((world, channels))
        }
        return results
    }
}
