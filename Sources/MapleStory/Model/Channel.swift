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
    
    public let address: MapleStoryAddress
        
    public var load: UInt32
    
    public var status: Status
        
    public var sessions: [Session.ID]
    
    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        index: Index,
        world: World.ID,
        name: String,
        address: MapleStoryAddress = .channelServerDefault,
        load: UInt32 = 0,
        status: Channel.Status = .normal,
        sessions: [Session.ID] = []
    ) {
        self.id = id
        self.index = index
        self.name = name
        self.address = address
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
        case address
        case load
        case status
    }
}

// MARK: - Entity

extension Channel: Entity {

    public init(from container: ModelData) throws {
        guard container.entity.rawValue == Self.entityName.rawValue else {
            throw CoreModel.CoreModelError.invalidEntity(container.entity)
        }
        guard let id = Self.ID(objectID: container.id) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Cannot decode identifier from \(container.id)"))
        }
        self.id = id
        self.index = try container.decode(Index.self, forKey: Channel.CodingKeys.index)
        self.name = try container.decode(String.self, forKey: Channel.CodingKeys.name)
        self.address = try container.decode(MapleStoryAddress.self, forKey: Channel.CodingKeys.address)
        self.load = try container.decode(UInt32.self, forKey: Channel.CodingKeys.load)
        self.status = try container.decode(Status.self, forKey: Channel.CodingKeys.status)
        self.world = try container.decodeRelationship(World.ID.self, forKey: Channel.CodingKeys.world)
        self.sessions = try container.decodeRelationship([Session.ID].self, forKey: Channel.CodingKeys.sessions)
    }

    public func encode() -> ModelData {
        var container = ModelData(
            entity: Self.entityName,
            id: ObjectID(self.id)
        )
        container.encode(self.index, forKey: Channel.CodingKeys.index)
        container.encode(self.name, forKey: Channel.CodingKeys.name)
        container.encode(self.address, forKey: Channel.CodingKeys.address)
        container.encode(self.load, forKey: Channel.CodingKeys.load)
        container.encode(self.status, forKey: Channel.CodingKeys.status)
        container.encodeRelationship(self.world, forKey: Channel.CodingKeys.world)
        container.encodeRelationship(self.sessions, forKey: Channel.CodingKeys.sessions)
        return container
    }

    public static var attributes: [CodingKeys: AttributeType] {
        [
            .name: .string,
            .index: .int16,
            .load: .int64,
            .status: .int16,
            .address: .string
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
