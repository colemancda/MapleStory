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
    func listWorlds() async throws -> [World] {
        log("World List")
        let database = server.dataSource.storage
        let version = await self.connection.version
        let region = await self.connection.region
        // fetch worlds
        var worlds = try await World.fetch(version: version, region: region, in: database)
        // lazily create worlds if none
        if worlds.isEmpty {
            worlds = try await World.insert(
                region: region,
                version: version,
                in: database
            )
        }
        return worlds
    }
}
