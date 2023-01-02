//
//  Channel.swift
//  
//
//  Created by Alsey Coleman Miller on 1/2/23.
//

import Foundation
import MapleStory
import Vapor
import Fluent

final class Channel: Model, Codable {
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case world
        case name
        case load
        case status
    }
    
    static let schema = "channels"
    
    @ID
    var id: UUID?
    
    @Parent(key: "world")
    var world: World
    
    @Field(key: CodingKeys.name)
    var name: String
    
    @Field(key: CodingKeys.load)
    var load: Int
    
    @Field(key: CodingKeys.status)
    var status: MapleStory.Channel.Status
    
    init() { }
    
    init(
        id: UUID? = nil,
        world: World.IDValue,
        name: String,
        load: UInt32 = 0,
        status: MapleStory.Channel.Status = .normal
    ) {
        self.id = id
        self.$world.id = world
        self.name = name
        self.load = numericCast(load)
        self.status = status
    }
}
