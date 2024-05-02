//
//  CharacterListRequest.swift
//
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import MapleStory

public struct CharacterListRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .characterListRequest }
    
    public let world: World.Index
    
    public let channel: Channel.Index
    
    public init(world: World.Index, channel: Channel.Index) {
        self.world = world
        self.channel = channel
    }
}
