//
//  PongPacket.swift
//  
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation

public struct PongPacket: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { .init(client: .pong) }
    
    public init() { }
}
