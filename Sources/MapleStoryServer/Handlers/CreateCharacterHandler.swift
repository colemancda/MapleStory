//
//  CreateCharacterHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory
import CoreModel

public extension MapleStoryServer.Connection {
    
    func createCharacter(
        _ values: Character.CreationValues
    ) async throws -> Character {
        log("Create character - \(values.name)")
        guard var user = try await self.user else {
            throw MapleStoryError.notAuthenticated
        }
        guard var world = try await self.world else {
            throw MapleStoryError.invalidRequest
        }
        let newCharacterID = world.newCharacter()
        let newCharacter = Character(
            create: values,
            index: newCharacterID,
            user: user.id,
            world: world.id
        )
        user.characters.append(newCharacter.id)
        world.characters.append(newCharacter.id)
        try await database.insert(newCharacter)
        try await database.insert(user)
        try await database.insert(world)
        return newCharacter
    }
}
