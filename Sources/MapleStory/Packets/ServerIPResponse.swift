//
//  ServerIPResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

import Foundation

public struct ServerIPResponse: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0C }
    
    public let value0: UInt16 // 0x0000
    
    public let address: MapleStoryAddress
    
    public let client: UInt32
    
    public let value1: UInt32
    
    public let value2: UInt8
}
