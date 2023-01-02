//
//  World.swift
//  
//
//  Created by Alsey Coleman Miller on 1/2/23.
//

import Foundation
import MapleStory
import SwiftBSON

extension MapleStory.World {
    
    struct BSON: Codable, Equatable, Hashable, Identifiable {
        
        static var collection: String { "worlds" }
        
        enum CodingKeys: String, CodingKey {
            
            case id = "_id"
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
        
        public let id: BSONObjectID
        
        public let index: UInt8
        
        public var name: String
        
        public var address: MapleStoryAddress
        
        public var flags: UInt8
        
        public var eventMessage: String
        
        public var rateModifier: UInt8
        
        public var eventXP: UInt8
            
        public var dropRate: UInt8
                
        public var channels: [Channel.BSON]
                
        init(
            id: BSONObjectID = BSONObjectID(),
            index: UInt8,
            name: String,
            address: MapleStoryAddress = .channelServerDefault,
            flags: UInt8 = 0x02,
            eventMessage: String = "",
            rateModifier: UInt8 = 0x64,
            eventXP: UInt8 = 0x00,
            dropRate: UInt8 = 0x00,
            channels: [Channel.BSON] = []
        ) {
            self.id = id
            self.index = (index)
            self.name = name
            self.address = address
            self.flags = (flags)
            self.eventMessage = eventMessage
            self.rateModifier = (rateModifier)
            self.eventXP = (eventXP)
            self.dropRate = (dropRate)
            self.channels = channels
        }
    }
    
    init(_ value: BSON) {
        self.init(
            id: value.index,
            name: value.name,
            address: value.address,
            flags: value.flags,
            eventMessage: value.eventMessage,
            rateModifier: value.rateModifier,
            eventXP: value.eventXP,
            dropRate: value.dropRate,
            channels: value.channels.enumerated().map {
                .init(id: UInt8($0.offset), $0.element)
            }
        )
    }
}

extension MapleStory.Channel {
    
    struct BSON: Codable, Equatable, Hashable {
        
        let name: String
        
        var load: UInt32
        
        var status: MapleStory.Channel.Status
    }
    
    init(id: UInt8, _ value: BSON) {
        self.init(id: id, name: value.name, load: value.load, status: value.status)
    }
}
