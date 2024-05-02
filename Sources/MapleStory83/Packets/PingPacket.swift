//
//  PingPacket.swift
//  
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation

public struct PingPacket: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .ping }
    
    public init() { }
}
