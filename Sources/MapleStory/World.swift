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
}

/// Channel
public struct Channel: Codable, Equatable, Hashable, Identifiable {
    
    public let id: UInt8
    
    public var name: String
    
    public var load: UInt32
    
    public var status: Status
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
