//
//  Buddy.swift
//  
//
//  Created by Coleman on 3/25/26.
//

import Foundation
import CoreModel

/// Buddy list relationship entity.
///
/// Represents a buddy relationship between two characters.
/// When `pending` is true, the buddy request has not yet been accepted.
/// When `pending` is false, the buddy is confirmed and visible in the list.
public struct Buddy: Codable, Equatable, Hashable, Identifiable, Sendable {
    
    // MARK: - Properties
    
    public let id: UUID
    
    /// The character who owns this buddy list entry
    public let character: Character.ID
    
    /// The buddy's character ID
    public let buddyID: Character.Index
    
    /// Whether this buddy request is pending acceptance
    public var pending: Bool
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        character: Character.ID,
        buddyID: Character.Index,
        pending: Bool = true
    ) {
        self.id = id
        self.character = character
        self.buddyID = buddyID
        self.pending = pending
    }
    
    // MARK: - Codable
    
    public enum CodingKeys: String, CodingKey, CaseIterable, Sendable {
        case id
        case character
        case buddyID
        case pending
    }
}

// MARK: - Entity

extension Buddy: Entity {

    public init(from container: ModelData) throws {
        guard container.entity.rawValue == Self.entityName.rawValue else {
            throw CoreModel.CoreModelError.invalidEntity(container.entity)
        }
        guard let id = Self.ID(objectID: container.id) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Cannot decode identifier from \(container.id)"))
        }
        self.id = id
        // `character` is a required foreign key that is intentionally not declared as a
        // relationship (managed by BuddyListRegistry) and has no default; persist it as an
        // attribute so it round-trips and the stored `let` is initialized.
        self.character = try container.decode(Character.ID.self, forKey: Buddy.CodingKeys.character)
        self.buddyID = try container.decode(Character.Index.self, forKey: Buddy.CodingKeys.buddyID)
        self.pending = try container.decode(Bool.self, forKey: Buddy.CodingKeys.pending)
    }

    public func encode() -> ModelData {
        var container = ModelData(
            entity: Self.entityName,
            id: ObjectID(self.id)
        )
        container.encode(self.character, forKey: Buddy.CodingKeys.character)
        container.encode(self.buddyID, forKey: Buddy.CodingKeys.buddyID)
        container.encode(self.pending, forKey: Buddy.CodingKeys.pending)
        return container
    }

    public static var attributes: [CodingKeys: AttributeType] {
        [
            .buddyID: .int64,
            .pending: .bool
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [:]  // No inverse relationship - managed by BuddyListRegistry
    }
}
