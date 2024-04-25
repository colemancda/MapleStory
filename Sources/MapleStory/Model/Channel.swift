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
    
    public let id: UUID
    
    public let index: Index
    
    public let world: World.ID
    
    public var name: String
    
    public var load: UInt32
    
    public var status: Status
    
    public init(
        id: UUID = UUID(),
        index: Index,
        world: World.ID,
        name: String,
        load: UInt32 = 0,
        status: Channel.Status = .normal
    ) {
        self.id = id
        self.index = index
        self.name = name
        self.load = load
        self.status = status
        self.world = world
    }
    
    public enum CodingKeys: CodingKey {
        
        case id
        case index
        case world
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
            .name: .string,
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
            )
        ]
    }
}
