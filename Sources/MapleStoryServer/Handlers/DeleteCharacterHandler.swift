//
//  DeleteCharacterHandler.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory
import CoreModel

public extension MapleStoryServer.Connection {
    
    func deleteCharacter(
        _ characterIndex: Character.Index,
        picCode: String? = nil,
        birthday: Date? = nil
    ) async throws {
        log("Delete Character - \(characterIndex)")
        // fetch client state, must be logged into a world
        guard var user = try await self.user else {
            throw MapleStoryError.notAuthenticated
        }
        guard var world = try await self.world else {
            throw MapleStoryError.invalidWorld
        }
        // validate PIC
        if let picCode,
           let isPicEnabled = try await database.fetch(configuration: .picEnabled)?.boolValue,
           isPicEnabled {
            guard user.picCode == picCode else {
                throw MapleStoryError.invalidPicCode
            }
        }
        // validate date of birth
        if let birthday {
            guard user.birthday == birthday else {
                throw MapleStoryError.invalidBirthday
            }
        }
        // fetch character
        guard let character = try await Character.fetch(characterIndex, user: user.id, world: world.id, in: database) else {
            throw MapleStoryError.invalidRequest
        }
        // remove from db
        user.characters.removeAll(where: { $0 == character.id })
        world.characters.removeAll(where: { $0 == character.id })
        try await database.delete(Character.self, for: character.id)
        try await database.insert(user)
        try await database.insert(world)
    }
}
