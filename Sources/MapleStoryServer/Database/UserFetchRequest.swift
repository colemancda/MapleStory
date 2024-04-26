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
    
    static func exists<Storage: ModelStorage>(
        with username: Username,
        in context: Storage
    ) async throws -> Bool {
        try await context.count(.init(fetchRequest: .username(username))) > 0
    }
    
    static func fetch<Storage: ModelStorage>(
        with username: Username,
        in context: Storage
    ) async throws -> User? {
        try await context.fetch(User.self, predicate: .init(predicate: .username(username)), fetchLimit: 1).first
    }
    
    static func fetch<Storage: ModelStorage>(
        with email: Email,
        in context: Storage
    ) async throws -> User? {
        try await context.fetch(User.self, predicate: .init(predicate: .email(email)), fetchLimit: 1).first
    }
    
    static func create<Storage: ModelStorage>(
        username: Username,
        password: Password,
        in context: Storage
    ) async throws {
        let hash = try password.hash()
        let newUser = User(
            username: username.sanitized(),
            password: hash
        )
        try await context.insert(newUser)
    }
    
    /// Attempt to register the specified user with the provided password.
    static func register<Storage: ModelStorage>(
        username: Username,
        password: Password,
        in context: Storage
    ) async throws -> Bool {
        // check if user exists
        guard try await User.exists(with: username, in: context) == false else {
            return false
        }
        // TODO: check if can create new user?
        // create new user
        try await User.create(
            username: username,
            password: password,
            in: context
        )
        return true
    }
    
    /// Validate the provided password for the specified user.
    static func validate<Storage: ModelStorage>(
        password: Password,
        for username: Username,
        in context: Storage
    ) async throws -> Bool {
        guard let user = try await fetch(with: username, in: context) else {
            throw MapleStoryError.unknownUser(username.rawValue)
        }
        return try password.validate(hash: user.password)
    }
}
