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
        
        case username(String)
        case email(Email)
        case ipAddress(String)
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
        case .ipAddress(let ipAddress):
            self.init(
                entity: User.entityName,
                predicate: .init(predicate: .ipAddress(ipAddress)),
                fetchLimit: 1
            )
        }
    }
}

// MARK: - Predicate

public extension User {
    
    enum Predicate {
        
        case username(String)
        case email(Email)
        case ipAddress(String)
    }
}

public extension FetchRequest.Predicate {
    
    init(predicate: User.Predicate) {
        switch predicate {
        case .username(let username):
            self = User.CodingKeys.id.stringValue.compare(.equalTo, [.caseInsensitive], .attribute(.string(username)))
        case .email(let email):
            self = User.CodingKeys.email.stringValue.compare(.equalTo, [.caseInsensitive], .attribute(.string(email.rawValue)))
        case .ipAddress(let ipAddress):
            self = User.CodingKeys.ipAddress.stringValue.compare(.equalTo, .attribute(.string(ipAddress)))
        }
    }
}

// MARK: - Storage

public extension User {
    
    static func exists<Storage: ModelStorage>(
        username: String,
        in context: Storage
    ) async throws -> Bool {
        try await context.count(.init(fetchRequest: .username(username))) > 0
    }
    
    static func fetch<Storage: ModelStorage>(
        username: String,
        in context: Storage
    ) async throws -> User? {
        try await context.fetch(User.self, predicate: .init(predicate: .username(username)), fetchLimit: 1).first
    }
    
    static func fetch<Storage: ModelStorage>(
        email: Email,
        in context: Storage
    ) async throws -> User? {
        try await context.fetch(User.self, predicate: .init(predicate: .email(email)), fetchLimit: 1).first
    }
    
    static func fetch<Storage: ModelStorage>(
        ipAddress: String,
        in context: Storage
    ) async throws -> User? {
        try await context.fetch(User.self, predicate: .init(predicate: .ipAddress(ipAddress)), fetchLimit: 1).first
    }
    
    /// Create a new user.
    @discardableResult
    static func create<Storage: ModelStorage>(
        username: Username,
        password: Password,
        ipAddress: String,
        isGuest: Bool = false,
        in context: Storage
    ) async throws -> User {
        let hash = try password.hash()
        let newUser = User(
            username: username.sanitized(),
            password: hash,
            ipAddress: ipAddress,
            isGuest: isGuest
        )
        try await context.insert(newUser)
        return newUser
    }
    
    /// Validate the provided password for the specified user.
    static func validate<Storage: ModelStorage>(
        password: String,
        for username: String,
        in context: Storage
    ) async throws -> Bool {
        guard let user = try await fetch(username: username, in: context) else {
            return false
        }
        return try user.validate(password: password)
    }
}
