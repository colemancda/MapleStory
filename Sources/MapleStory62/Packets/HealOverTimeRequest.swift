//
//  HealOverTimeRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct HealOverTimeRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .healOverTime }
    
    internal let value0: UInt8
    
    internal let value1: UInt16
    
    internal let value2: UInt8
    
    public let hp: UInt16
    
    public let mp: UInt16
    
    internal let value3: UInt8
}
