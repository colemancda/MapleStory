//
//  ConfigurationFetchRequest.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import Foundation
import CoreModel
import MapleStory

// MARK: - Predicate

public extension Configuration {
    
    /// Create a new User ID
    static func newUserIndex<Storage: ModelStorage>(
        in context: Storage
    ) async throws -> User.Index {
        let index = try await lastUserIndex(in: context)
        let newIndex = index + 1
        var configuration = Configuration(id: .lastUserIndex, value: newIndex.description)
        try await context.insert(configuration)
        return index
    }
    
    /// Last User ID
    static func lastUserIndex<Storage: ModelStorage>(
        in context: Storage
    ) async throws -> User.Index {
        try await context.fetch(Configuration.self, for: .lastUserIndex)?.lastUserID ?? 1
    }
}
