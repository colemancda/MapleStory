//
//  StorageFetchRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/25/26.
//

import Foundation
import CoreModel
import MapleStory

// MARK: - Predicate

public extension Storage {
    
    enum Predicate {
        
        case userID(User.ID)
    }
}

public extension FetchRequest.Predicate {
    
    init(predicate: Storage.Predicate) {
        switch predicate {
        case .userID(let userID):
            self = Storage.CodingKeys.userID.stringValue.compare(.equalTo, .attribute(.string(userID.rawValue)))
        }
    }
}

// MARK: - Storage

public extension Storage {
    
    static func fetch<Storage: ModelStorage>(
        userID: User.ID,
        in context: Storage
    ) async throws -> Storage? {
        try await context.fetch(Storage.self, predicate: .init(predicate: .userID(userID)), fetchLimit: 1).first
    }
    
    static func fetchOrCreate<Storage: ModelStorage>(
        userID: User.ID,
        in context: Storage
    ) async throws -> Storage {
        if let existing = try await fetch(userID: userID, in: context) {
            return existing
        }
        let newStorage = Storage(
            userID: userID,
            mesos: 0,
            maxSlots: 16,
            items: [:]
        )
        try await context.insert(newStorage)
        return newStorage
    }
}