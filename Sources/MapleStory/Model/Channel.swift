//
//  Channel.swift
//  
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import CoreModel

/// Channel
public struct Channel: Codable, Equatable, Hashable, Identifiable, Sendable {
    
    public typealias Index = UInt8
    
    // MARK: - Properties
    
    public let id: UUID
    
    public let index: Index
    
    public let world: World.ID
    
    public var name: String
        
    public var load: UInt32
    
    public var status: Status
    
    public var sessions: [Session.ID]
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        index: Index,
        world: World.ID,
        name: String,
        load: UInt32 = 0,
        status: Channel.Status = .normal,
        sessions: [Session.ID] = []
    ) {
        self.id = id
        self.index = index
        self.name = name
        self.load = load
        self.status = status
        self.world = world
        self.sessions = sessions
    }
    
    // MARK: - Codable
    
    public enum CodingKeys: String, CodingKey, CaseIterable, Sendable {
        
        case id
        case index
        case world
        case sessions
        case name
        case load
        case status
    }
}

// MARK: - Entity

extension Channel: Entity {
    
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .name: .string,
            .index: .int16,
            .load: .int64,
            .status: .int16
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .world: Relationship(
                id: .world,
                entity: Channel.self,
                destination: World.self,
                type: .toOne,
                inverseRelationship: .channels
            ),
            .sessions: Relationship(
                id: .sessions,
                entity: Channel.self,
                destination: Session.self,
                type: .toMany,
                inverseRelationship: .channel
            )
        ]
    }
}
