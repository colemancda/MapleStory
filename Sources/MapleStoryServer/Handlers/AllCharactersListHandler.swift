//
//  AllCharactersListHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory
import CoreModel

public extension MapleStoryServer.Connection {
    
    func characterList() async throws -> [(world: World.Index, characters: [Character])] {
        log("All Character List")
        guard let user = self.state.user else {
            throw MapleStoryError.notAuthenticated
        }
        let characters = try await Character.fetch(
            user: user,
            in: database
        )
        let worlds = try await World.fetch(
            version: version,
            region: region,
            in: database
        )
        // sort in memory
        var charactersByWorld = [World.Index: [Character]]()
        charactersByWorld.reserveCapacity(10)
        for character in characters {
            guard let world = worlds.first(where: { $0.id == character.world }) else {
                continue
            }
            charactersByWorld[world.index, default: []].reserveCapacity(6)
            charactersByWorld[world.index, default: []].append(character)
        }
        return charactersByWorld
            .lazy
            .sorted(by: { $0.key < $1.key })
            .map { ($0.key, $0.value) }
    }
}
