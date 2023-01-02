//
//  World.swift
//  
//
//  Created by Alsey Coleman Miller on 1/2/23.
//

import Foundation
import struct MapleStory.MapleStoryAddress
import Vapor
import Fluent

final class World: Model, Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case index
        case name
        case address
        case flags
        case eventMessage
        case rateModifier
        case eventXP
        case dropRate
        case channels
    }
    
    static let schema = "worlds"
    
    @ID
    var id: UUID?
    
    @Field(key: CodingKeys.index)
    var index: Int
    
    @Field(key: CodingKeys.name)
    var name: String
    
    @Field(key: CodingKeys.address)
    var address: MapleStoryAddress
    
    @Field(key: CodingKeys.flags)
    var flags: Int
    
    @Field(key: CodingKeys.eventMessage)
    var eventMessage: String
    
    @Field(key: CodingKeys.rateModifier)
    var rateModifier: Int
    
    @Field(key: CodingKeys.eventXP)
    var eventXP: Int
    
    @Field(key: CodingKeys.dropRate)
    var dropRate: Int
    
    @Children(for: \.$world)
    var channels: [Channel]
    
    init() { }
    
    init(
        id: UUID? = nil,
        index: UInt8,
        name: String,
        address: MapleStoryAddress = .channelServerDefault,
        flags: UInt8 = 0x02,
        eventMessage: String = "",
        rateModifier: UInt8 = 0x64,
        eventXP: UInt8 = 0x00,
        dropRate: UInt8 = 0x00
    ) {
        self.id = id
        self.index = numericCast(index)
        self.name = name
        self.address = address
        self.flags = numericCast(flags)
        self.eventMessage = eventMessage
        self.rateModifier = numericCast(rateModifier)
        self.eventXP = numericCast(eventXP)
        self.dropRate = numericCast(dropRate)
    }
}
