//
//  SessionFetchRequest.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation
import CoreModel
import MapleStory

// MARK: - Predicate

public extension Session {
    
    enum Predicate {
        
        case character(Character.ID)
        case channel(Channel.ID)
    }
}

public extension Session.Predicate {
    
    var key: Session.CodingKeys {
        switch self {
        case .character:
            return .character
        case .channel:
            return .channel
        }
    }
}

public extension FetchRequest.Predicate {
    
    init(predicate: Session.Predicate) {
        let key = predicate.key.stringValue
        switch predicate {
        case .character(let character):
            self = key.compare(.equalTo, .relationship(.toOne(.init(character))))
        case .channel(let channel):
            self = key.compare(.equalTo, .relationship(.toOne(.init(channel))))
        }
    }
}

public extension Session {
    
    static func fetch<Storage: ModelStorage>(
        character: Character.ID,
        channel: Channel.ID? = nil,
        in database: Storage
    ) async throws -> Session? {
        var predicates: [Session.Predicate] = [
            .character(character),
        ]
        if let channel {
            predicates.append(
                .channel(channel)
            )
        }
        let predicate = FetchRequest.Predicate.compound(.and(predicates.map { .init(predicate: $0) }))
        return try await database.fetch(
            Session.self,
            sortDescriptors: [
                .init(property: .init(Session.CodingKeys.requestTime), ascending: true)
            ],
            predicate: predicate,
            fetchLimit: 1
        ).first
    }
}
