//
//  World.swift
//  
//
//  Created by Alsey Coleman Miller on 12/25/22.
//

import Foundation
import CoreModel

public struct World: Equatable, Hashable, Codable, Identifiable {
    
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
        channels: [Channel.ID] = []
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
    }
}