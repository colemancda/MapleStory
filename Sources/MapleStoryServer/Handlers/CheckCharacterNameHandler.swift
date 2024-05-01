//
//  CheckCharacterNameHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory
import CoreModel

public extension MapleStoryServer.Connection {
    
    func checkCharacterName(
        _ name: String
    ) async throws -> Bool {
        log("Check Character Name - \(name)")
        guard let world = state.world else {
            throw MapleStoryError.invalidRequest
        }
        guard let name = CharacterName(rawValue: name) else {
            return false
        }
        return try await Character.exists(name: name, world: world, in: database) == false
    }
}
