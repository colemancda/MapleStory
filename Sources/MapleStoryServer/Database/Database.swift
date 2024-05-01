//
//  Database.swift
//  
//
//  Created by Alsey Coleman Miller on 12/30/22.
//

import Foundation
import ArgumentParser
import MapleStory
import CoreModel

public extension ModelStorage {
    
    func initializeMapleStory(
        version: MapleStory.Version,
        region: MapleStory.Region,
        address: String = "127.0.0.1"
    ) async throws {
        // create worlds
        var worlds = try await World.fetch(
            version: version,
            region: region,
            in: self
        )
        // lazily create worlds if none
        if worlds.isEmpty {
            worlds = try await World.insert(
                region: region,
                version: version,
                address: address,
                in: self
            )
        }
        // create configuration
        var configuration = try await fetch(Configuration.self)
        if configuration.isEmpty {
            configuration = .default
            try await insert(configuration)
        }
        
    }
}
