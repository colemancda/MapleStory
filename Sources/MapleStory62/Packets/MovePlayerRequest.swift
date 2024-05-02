//
//  MovePlayerRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct MovePlayerRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .movePlayer }
    
    internal let value0: UInt8
    
    internal let value1: UInt32
    
    public let movements: [Movement]
    
    internal let value2: UInt64
    
    internal let value3: UInt64
    
    internal let value4: UInt16
}
