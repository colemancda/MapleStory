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
        case address(String)
    }
}

public extension Session.Predicate {
    
    var key: Session.CodingKeys {
        switch self {
        case .character:
            return .character
        case .channel:
            return .channel
        case .address:
            return .address
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
        case .address(let address):
            self = key.compare(.equalTo, .attribute(.string(address)))
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
        let predicate: FetchRequest.Predicate
        if predicates.count > 1 {
            predicate = .compound(.and(predicates.map { .init(predicate: $0) }))
        } else {
            predicate = .init(predicate: predicates[0])
        }
        return try await database.fetch(
            Session.self,
            sortDescriptors: [
                .init(property: .init(Session.CodingKeys.requestTime), ascending: true)
            ],
            predicate: predicate,
            fetchLimit: 1
        ).first
    }
    
    static func fetch<Storage: ModelStorage>(
        address: String,
        character: Character.ID? = nil,
        channel: Channel.ID? = nil,
        in database: Storage
    ) async throws -> Session? {
        var predicates: [Session.Predicate] = [
            .address(address)
        ]
        if let channel {
            predicates.append(
                .channel(channel)
            )
        }
        if let character {
            predicates.append(
                .character(character)
            )
        }
        let predicate: FetchRequest.Predicate
        if predicates.count > 1 {
            predicate = .compound(.and(predicates.map { .init(predicate: $0) }))
        } else {
            predicate = .init(predicate: predicates[0])
        }
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
