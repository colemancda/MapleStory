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
        case user(User.ID)
        case world(World.ID)
        case session(Session.ID)
    }
}

public extension Character.Predicate {
    
    var key: Character.CodingKeys {
        switch self {
        case .name:
            return .name
        case .index:
            return .index
        case .session:
            return .session
        case .user:
            return .user
        case .world:
            return .world
        }
    }
}

public extension FetchRequest.Predicate {
    
    init(predicate: Character.Predicate) {
        let key = predicate.key.stringValue
        switch predicate {
        case .name(let name):
            self = key.compare(.equalTo, .attribute(.string(name.rawValue.lowercased())))
        case .index(let index):
            self = key.compare(.equalTo, .attribute(.int64(numericCast(index))))
        case .user(let user):
            self = key.compare(.equalTo, .relationship(.toOne(.init(user))))
        case .world(let world):
            self = key.compare(.equalTo, .relationship(.toOne(.init(world))))
        case .session(let session):
            self = key.compare(.equalTo, .relationship(.toOne(.init(session))))
        }
    }
}

public extension Character {
    
    static func exists<Storage: ModelStorage>(
        name: CharacterName,
        world: World.ID,
        in database: Storage
    ) async throws -> Bool {
        let predicates: [Character.Predicate] = [
            .name(name),
            .world(world)
        ]
        let predicate = FetchRequest.Predicate.compound(.and(predicates.map { .init(predicate: $0) }))
        let count = try await database.count(Character.self, predicate: predicate, fetchLimit: 1)
        return count > 0
    }
    
    static func fetch<Storage: ModelStorage>(
        user: User.ID,
        world: World.ID? = nil,
        in database: Storage
    ) async throws -> [Character] {
        var predicates: [Character.Predicate] = [
            .user(user)
        ]
        if let world {
            predicates.append(
                .world(world)
            )
        }
        let predicate = FetchRequest.Predicate.compound(.and(predicates.map { .init(predicate: $0) }))
        return try await database.fetch(
            Character.self, 
            sortDescriptors: [
                .init(property: .init(Character.CodingKeys.index), ascending: true)
            ],
            predicate: predicate
        )
    }
    
    static func fetch<Storage: ModelStorage>(
        _ index: Character.Index,
        user: User.ID? = nil,
        world: World.ID,
        in database: Storage
    ) async throws -> Character? {
        var predicates: [Character.Predicate] = [
            .index(index),
            .world(world)
        ]
        if let user {
            predicates.append(.user(user))
        }
        let predicate = FetchRequest.Predicate.compound(.and(predicates.map { .init(predicate: $0) }))
        return try await database.fetch(
            Character.self,
            sortDescriptors: [
                .init(property: .init(Character.CodingKeys.index), ascending: true)
            ],
            predicate: predicate,
            fetchLimit: 1
        ).first
    }
}
