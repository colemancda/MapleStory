//
//  CharacterListRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct CharacterListRequest: MapleStoryPacket, Decodable, Equatable, Hashable {
    
    public static var opcode: Opcode { .init(client: .characterListRequest) }
    
    internal var value0: UInt8
    
    public let world: World.Index
    
    public let channel: Channel.Index
    
    public init(world: World.Index, channel: Channel.Index) {
        self.world = world
        self.channel = channel
        self.value0 = 0x00
    }
}
