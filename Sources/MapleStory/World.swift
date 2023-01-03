//
//  World.swift
//  
//
//  Created by Alsey Coleman Miller on 12/25/22.
//

import Foundation

public struct World: Equatable, Hashable, Codable, Identifiable {
    
    public let id: UInt8
    
    public var name: String
    
    public var address: MapleStoryAddress
    
    public var flags: UInt8
    
    public var eventMessage: String
    
    public var rateModifier: UInt8
    
    public var eventXP: UInt8
        
    public var dropRate: UInt8
            
    public var channels: [Channel]
    
    public init(
        id: UInt8,
        name: String,
        address: MapleStoryAddress = .channelServerDefault,
        flags: UInt8 = 0x02,
        eventMessage: String = "",
        rateModifier: UInt8 = 0x64,
        eventXP: UInt8 = 0,
        dropRate: UInt8 = 0,
        channels: [Channel] = []
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.flags = flags
        self.eventMessage = eventMessage
        self.rateModifier = rateModifier
        self.eventXP = eventXP
        self.dropRate = dropRate
        self.channels = channels
    }
}

public extension World {
    
    enum Name: String, CaseIterable {
        
        case scania     = "Scania"
        case bera       = "Bera"
        case broa       = "Broa"
        case windia     = "Windia"
        case khaini     = "Khaini"
        case bellocan   = "Bellocan"
        case mardia     = "Mardia"
        case kradia     = "Kradia"
        case yellonde   = "Yellonde"
        case demethos   = "Demethos"
        case elnido     = "Elnido"
        case kastia     = "Kastia"
        case judis      = "Judis"
        case arkenia    = "Arkenia"
        case plana      = "Plana"
        
        init?(id: World.ID) {
            guard let value = Self.allCases.enumerated().first(where: { $0.offset == id })?.element else {
                return nil
            }
            self = value
        }
        
        var id: World.ID {
            World.ID(Self.allCases.firstIndex(of: self)!)
        }
    }
    
    static func name(for id: World.ID) -> String {
        guard let name = Name(id: id) else {
            return "World \(id + 1)"
        }
        return name.rawValue
    }
}

/// Channel
public struct Channel: Codable, Equatable, Hashable, Identifiable {
    
    public let id: UInt8
    
    public var name: String
    
    public var load: UInt32
    
    public var status: Status
    
    public init(
        id: UInt8,
        name: String,
        load: UInt32 = 0,
        status: Channel.Status = .normal
    ) {
        self.id = id
        self.name = name
        self.load = load
        self.status = status
    }
}

public extension Channel {
    
    enum Status: UInt8, Codable, CaseIterable {
        
        /// Normal
        case normal         = 0
        
        /// High Usage
        case highUsage      = 1
        
        /// Full
        case full           = 2
    }
}
