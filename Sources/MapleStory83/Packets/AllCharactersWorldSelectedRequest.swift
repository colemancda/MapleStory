//
//  AllCharactersWorldSelectedRequest.swift
//
//
//  Created by Alsey Coleman Miller on 5/4/24.
//

import Foundation
import MapleStory

public struct AllCharactersWorldSelectedRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .viewAllCharactersWorldSelected }
    
    public let world: World.Index
    
    public init(world: World.Index) {
        self.world = world
    }
}
