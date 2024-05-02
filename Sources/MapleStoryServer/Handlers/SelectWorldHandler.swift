//
//  WorldSelectionHandler.swift
//
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import CoreModel
import MapleStory

public extension MapleStoryServer.Connection {
    
    /// Handle world selection.
    func selectWorld(
        _ worldIndex: World.Index
    ) async throws -> (warning: Channel.Status, population: Channel.Status) {
        log("Select World \(worldIndex)")
        
        guard let world = try await World.fetch(
            index: worldIndex,
            version: version,
            region: region,
            in: database
        ) else {
            throw MapleStoryError.invalidRequest
        }
        
        // update client state
        state.world = world.id
        
        return (.normal, .normal) // hardcoded for now
    }
}
