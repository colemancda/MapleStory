//
//  UserFetchRequest.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import CoreModel
import MapleStory

public extension User {
    
    enum FetchRequest {
        
        case username(Username)
        case email(Email)
    }
}

public extension FetchRequest {
    
    init(fetchRequest: User.FetchRequest) {
        switch fetchRequest {
        case .username(let username):
            self.init(
                entity: User.entityName,
                predicate: .init(predicate: .username(username)),
                fetchLimit: 1
            )
        case .email(let email):
            self.init(
                entity: User.entityName,
                predicate: .init(predicate: .email(email)),
                fetchLimit: 1
            )
        }
    }
}

// MARK: - Predicate

public extension User {
    
    enum Predicate {
        
        case username(Username)
        case email(Email)
    }
}

public extension FetchRequest.Predicate {
    
    init(predicate: User.Predicate) {
        switch predicate {
        case .username(let username):
            self = User.CodingKeys.id.stringValue.compare(.equalTo, [.caseInsensitive], .attribute(.string(username.rawValue)))
        case .email(let email):
            self = User.CodingKeys.email.stringValue.compare(.equalTo, [.caseInsensitive], .attribute(.string(email.rawValue)))
        }
    }
}

// MARK: - Storage

public extension User {
    
    func exists<Storage: ModelStorage>(
        with username: Username,
        in context: Storage
    ) async throws -> Bool {
        try await context.count(.init(fetchRequest: .username(username))) > 0
    }
    
    func fetch<Storage: ModelStorage>(
        with username: Username,
        in context: Storage
    ) async throws -> User? {
        try await context.fetch(User.self, predicate: .init(predicate: .username(username)), fetchLimit: 1).first
    }
    
    func fetch<Storage: ModelStorage>(
        with email: Email,
        in context: Storage
    ) async throws -> User? {
        try await context.fetch(User.self, predicate: .init(predicate: .username(username)), fetchLimit: 1).first
    }
}
