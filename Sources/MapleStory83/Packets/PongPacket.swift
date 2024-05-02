//
//  PongPacket.swift
//  
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import MapleStory

public struct PongPacket: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .pong }
    
    public init() { }
}
