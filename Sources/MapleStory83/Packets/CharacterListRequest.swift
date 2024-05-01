//
//  CharacterListRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct CharacterListRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: Opcode { .init(client: .characterListRequest) }
    
    internal let value0: UInt8
    
    public let world: World.Index
    
    public let channel: Channel.Index
    
    internal let value1: UInt32
    
    public init(
        world: World.Index,
        channel: Channel.Index
    ) {
        self.world = world
        self.channel = channel
        self.value0 = 0x00
        self.value1 = 0x00
    }
    
    internal init(value0: UInt8, world: World.Index, channel: Channel.Index, value1: UInt32) {
        self.value0 = value0
        self.world = world
        self.channel = channel
        self.value1 = value1
    }
}
