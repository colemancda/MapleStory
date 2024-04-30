//
//  ChannelFetchRequest.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import CoreModel
import MapleStory

// MARK: - Predicate

public extension Channel {
    
    enum Predicate {
        
        case index(Channel.Index)
        case world(World.ID)
    }
}

public extension FetchRequest.Predicate {
    
    init(predicate: Channel.Predicate) {
        switch predicate {
        case .index(let index):
            self = Channel.CodingKeys.index.stringValue.compare(.equalTo, .attribute(.int16(numericCast(index))))
        case .world(let world):
            self = Channel.CodingKeys.world.stringValue.compare(.equalTo, .relationship(.toOne(.init(world))))
        }
    }
}

extension Channel {
    
    static func fetch<Storage: ModelStorage>(
        _ index: Channel.Index,
        world: World.ID,
        in database: Storage
    ) async throws -> Channel? {
        let predicates = [
            FetchRequest.Predicate(predicate: Channel.Predicate.index(index)),
            FetchRequest.Predicate(predicate: Channel.Predicate.world(world))
        ]
        let predicate = FetchRequest.Predicate.compound(.and(predicates))
        return try await database.fetch(Channel.self, predicate: predicate, fetchLimit: 1).first
    }
}
