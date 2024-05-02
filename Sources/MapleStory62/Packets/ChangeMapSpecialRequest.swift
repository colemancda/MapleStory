//
//  ChangeMapSpecialRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/23/22.
//

import Foundation

public struct ChangeMapSpecialRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .changeMapSpecial }
    
    internal let value0: UInt8
    
    public let startwp: String
    
    internal let value1: UInt16
    
    internal let value2: UInt16
}
