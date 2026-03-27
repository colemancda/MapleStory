//
//  PartyEntity.swift
//
//
//  Created by Alsey Coleman Miller on 3/25/26.
//

import Foundation
import CoreModel

/// Party entity (persisted in database)
public struct PartyEntity: Codable, Equatable, Hashable, Identifiable, Sendable {
    
    public typealias ID = UUID
    
    public let id: ID
    
    /// The UInt32 party ID used for protocol communication
    public let partyID: PartyID
    
    /// Party leader
    public var leaderID: Character.ID
    
    /// When the party was created
    public var createdAt: Date
    
    public init(
        id: ID = UUID(),
        partyID: PartyID,
        leaderID: Character.ID,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.partyID = partyID
        self.leaderID = leaderID
        self.createdAt = createdAt
    }
    
    // MARK: - Codable
    
    public enum CodingKeys: String, CodingKey, CaseIterable, Sendable {
        case id
        case partyID
        case leaderID
        case createdAt
    }
}

// MARK: - Entity

extension PartyEntity: Entity {
    
    public static var entityName: EntityName { "Party" }
    
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .partyID: .int64,
            .createdAt: .date
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .leaderID: Relationship(
                id: .leaderID,
                entity: PartyEntity.self,
                destination: Character.self,
                type: .toOne,
                inverseRelationship: .party
            )
        ]
    }
}

