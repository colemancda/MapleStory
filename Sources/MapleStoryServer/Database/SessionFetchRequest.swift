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
        address: String,
        channel: Channel.ID,
        in database: Storage
    ) async throws -> Session? {
        let predicates: [Session.Predicate] = [
            .address(address),
            .channel(channel)
        ]
        return try await database.fetch(
            Session.self,
            sortDescriptors: [
                .init(property: .init(Session.CodingKeys.requestTime), ascending: false) // most rescent
            ],
            predicate: .compound(.and(predicates.map { .init(predicate: $0) })),
            fetchLimit: 1
        ).first
    }
}
