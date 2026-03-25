//
//  PartyEntity.swift
//
//
//  Created by Alsey Coleman Miller on 3/25/26.
//

import Foundation
import CoreModel
import MapleStory

/// Party entity (persisted in database)
public struct PartyEntity: Codable, Equatable, Hashable, Identifiable, Sendable {
    
    public typealias ID = UUID
    
    public let id: ID
    
    /// Party leader
    public var leaderID: Character.ID
    
    /// When the party was created
    public var createdAt: Date
    
    public init(
        id: ID = UUID(),
        leaderID: Character.ID,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.leaderID = leaderID
        self.createdAt = createdAt
    }
}