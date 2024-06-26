//
//  UserFetchRequest.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import CoreModel
import MapleStory

// MARK: - Predicate

public extension User {
    
    enum Predicate {
        
        case index(User.Index)
        case username(Username)
        case email(Email)
        case ipAddress(String)
        case isGuest(Bool)
    }
}

public extension FetchRequest.Predicate {
    
    init(predicate: User.Predicate) {
        switch predicate {
        case .index(let index):
            self = User.CodingKeys.index.stringValue.compare(.equalTo, .attribute(.int64(numericCast(index))))
        case .username(let username):
            self = User.CodingKeys.username.stringValue.compare(.equalTo, .attribute(.string(username.sanitized().rawValue)))
        case .email(let email):
            self = User.CodingKeys.email.stringValue.compare(.equalTo, .attribute(.string(email.rawValue.lowercased())))
        case .ipAddress(let ipAddress):
            self = User.CodingKeys.ipAddress.stringValue.compare(.equalTo, .attribute(.string(ipAddress)))
        case .isGuest(let isGuest):
            self = User.CodingKeys.isGuest.stringValue.compare(.equalTo, .attribute(.bool(isGuest)))
        }
    }
}

// MARK: - Storage

public extension User {
    
    static func exists<Storage: ModelStorage>(
        username: Username,
        in context: Storage
    ) async throws -> Bool {
        let fetchRequest = FetchRequest(
            entity: User.entityName,
            predicate: .init(predicate: .username(username)),
            fetchLimit: 1
        )
        return try await context.count(fetchRequest) > 0
    }
    
    static func fetch<Storage: ModelStorage>(
        username: Username,
        in context: Storage
    ) async throws -> User? {
        try await context.fetch(User.self, predicate: .init(predicate: .username(username)), fetchLimit: 1).first
    }
    
    static func fetch<Storage: ModelStorage>(
        index: User.Index,
        in context: Storage
    ) async throws -> User? {
        try await context.fetch(User.self, predicate: .init(predicate: User.Predicate.index(index)), fetchLimit: 1).first
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
    ) async throws -> [User] {
        try await context.fetch(User.self, predicate: .init(predicate: .ipAddress(ipAddress)))
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
        // fetch and modify user ID
        var index = try await context.fetch(configuration: .lastUserIndex)?.intValue ?? 0
        index += 1
        try await context.insert(.init(integer: index), for: .lastUserIndex)
        // create user
        let hash = try password.hash()
        let newUser = User(
            index: index, 
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
        password: Password,
        for username: Username,
        in context: Storage
    ) async throws -> Bool {
        guard let user = try await fetch(username: username, in: context) else {
            return false
        }
        return try user.validate(password: password.rawValue)
    }
}
