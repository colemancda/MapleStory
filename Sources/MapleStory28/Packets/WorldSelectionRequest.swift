//
//  WorldSelectRequest.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

public struct WorldSelectionRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .loginWorldSelect }
        
    public let world: World.Index
    
    internal let value0: UInt8
    
    public init(
        world: World.Index
    ) {
        self.world = world
        self.value0 = 0x00
    }
}
