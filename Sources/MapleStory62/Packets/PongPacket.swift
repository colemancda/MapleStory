//
//  PongPacket.swift
//  
//
//  Created by Alsey Coleman Miller on 12/16/22.
//

import Foundation

public struct PongPacket: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .pong }
    
    public init() { }
}
