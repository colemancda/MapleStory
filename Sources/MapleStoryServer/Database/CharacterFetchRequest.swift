//
//  CharacterFetchRequest.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import CoreModel
import MapleStory

// MARK: - Predicate

public extension Character {
    
    enum Predicate {
        
        case name(CharacterName)
        case index(Character.Index)
        case channel(Channel.ID)
        case user(User.ID)
        case world(World.ID)
    }
}

public extension FetchRequest.Predicate {
    
    init(predicate: Character.Predicate) {
        switch predicate {
        case .name(let name):
            self = Character.CodingKeys.name.stringValue.compare(.equalTo, .attribute(.string(name.rawValue.lowercased())))
        case .index(let index):
            self = Character.CodingKeys.index.stringValue.compare(.equalTo, .attribute(.int64(numericCast(index))))
        case .channel(let channel):
            self = Character.CodingKeys.channel.stringValue.compare(.equalTo, .relationship(.toOne(.init(channel))))
        case .user(let user):
            self = Character.CodingKeys.user.stringValue.compare(.equalTo, .relationship(.toOne(.init(user))))
        case .world(let world):
            self = Character.CodingKeys.world.stringValue.compare(.equalTo, .relationship(.toOne(.init(world))))
        }
    }
}

public extension Character {
    
    static func exists<Storage: ModelStorage>(
        name: CharacterName,
        world: World.ID,
        in database: Storage
    ) async throws -> Bool {
        let predicates = [
            FetchRequest.Predicate.init(predicate: Character.Predicate.name(name)),
            FetchRequest.Predicate.init(predicate: Character.Predicate.world(world))
        ]
        let predicate = FetchRequest.Predicate.compound(.and(predicates))
        let count = try await database.count(Character.self, predicate: predicate, fetchLimit: 1)
        return count > 0
    }
    
    static func fetch<Storage: ModelStorage>(
        user: User.ID,
        world: World.ID? = nil,
        channel: Channel.ID? = nil,
        in database: Storage
    ) async throws -> [Character] {
        var predicates = [
            FetchRequest.Predicate.init(predicate: Character.Predicate.user(user))
        ]
        if let world {
            predicates.append(
                .init(predicate: Character.Predicate.world(world))
            )
        }
        if let channel {
            predicates.append(
                .init(predicate: Character.Predicate.channel(channel))
            )
        }
        let predicate = FetchRequest.Predicate.compound(.and(predicates))
        return try await database.fetch(
            Character.self, 
            sortDescriptors: [
                .init(property: .init(Character.CodingKeys.index), ascending: true)
            ],
            predicate: predicate
        )
    }
}
