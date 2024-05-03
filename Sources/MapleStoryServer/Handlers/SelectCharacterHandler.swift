//
//  SelectCharacterHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

public extension MapleStoryServer.Connection {
    
    /// Select Character
    func selectCharacter(
        _ characterIndex: Character.Index
    ) async throws -> MapleStoryAddress {
        log("Select Character \(characterIndex)")
        guard let user = try await self.user else {
            throw MapleStoryError.notAuthenticated
        }
        guard let world = try await self.world else {
            throw MapleStoryError.invalidWorld
        }
        guard let channel = try await self.channel else {
            throw MapleStoryError.invalidChannel
        }
        // TODO: Add session in DB
        return world.address
    }
}
