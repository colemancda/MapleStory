//
//  PongPacket.swift
//  
//
//  Created by Alsey Coleman Miller on 12/16/22.
//

import Foundation

public struct PongPacket: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0018 }
    
    public init() { }
}
