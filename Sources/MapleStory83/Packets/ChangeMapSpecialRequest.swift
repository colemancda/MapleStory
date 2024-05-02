//
//  ChangeMapSpecialRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct ChangeMapSpecialRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .changeMap }
    
    internal let value0: UInt8
    
    public let startwp: String
    
    internal let value1: UInt16
    
    internal let value2: UInt16
}
