//
//  World.swift
//  
//
//  Created by Alsey Coleman Miller on 12/25/22.
//

import Foundation
import CoreModel

public struct World: Equatable, Hashable, Codable, Identifiable, Sendable {
    
    public typealias Index = UInt8
    
    public let id: UUID
    
    public let index: Index
    
    public let region: Region
    
    public let version: Version
    
    public var name: String
    
    public var address: MapleStoryAddress
    
    public var flags: UInt8
    
    public var eventMessage: String
    
    public var rateModifier: UInt8
    
    public var eventXP: UInt8
        
    public var dropRate: UInt8
            
    public var channels: [Channel.ID]
    
    public var lastCharacter: Character.Index?
    
    public var lastGuest: UInt32?
    
    public init(
        id: UUID = UUID(),
        index: Index = 0,
        name: String = World.Name.scania.rawValue,
        region: Region = .global,
        version: Version,
        address: MapleStoryAddress = .channelServerDefault,
        flags: UInt8 = 0x02,
        eventMessage: String = "",
        rateModifier: UInt8 = 0x64,
        eventXP: UInt8 = 0,
        dropRate: UInt8 = 0,
        channels: [Channel.ID] = [],
        lastCharacter: Character.Index? = nil
    ) {
        self.id = id
        self.index = index
        self.name = name
        self.address = address
        self.region = region
        self.version = version
        self.flags = flags
        self.eventMessage = eventMessage
        self.rateModifier = rateModifier
        self.eventXP = eventXP
        self.dropRate = dropRate
        self.channels = channels
        self.lastCharacter = lastCharacter
    }
    
    public enum CodingKeys: String, CodingKey, CaseIterable {
        
        case id
        case index
        case region
        case version
        case name
        case address
        case flags
        case eventMessage
        case rateModifier
        case eventXP
        case dropRate
        case channels
        case lastCharacter
    }
}

// MARK: - Methods

public extension World {
    
    mutating func newCharacter() -> Character.Index {
        var index = self.lastCharacter ?? 0
        index += 1
        self.lastCharacter = index
        return index
    }
}

// MARK: - Entity

extension World: Entity {
    
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .name: .string,
            .index: .int16,
            .region: .int16,
            .version: .int32,
            .address: .string,
            .flags: .int16,
            .eventMessage: .string,
            .rateModifier: .int16,
            .eventXP: .int16,
            .dropRate: .int16,
            .lastCharacter: .int64
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .channels: Relationship(
                id: .channels,
                entity: World.self,
                destination: Channel.self,
                type: .toMany,
                inverseRelationship: .world
            )
        ]
    }
}
