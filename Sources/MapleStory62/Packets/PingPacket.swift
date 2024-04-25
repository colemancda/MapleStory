//
//  PingPacket.swift
//  
//
//  Created by Alsey Coleman Miller on 12/16/22.
//

import Foundation

public struct PingPacket: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0011 }
    
    public init() { }
}
