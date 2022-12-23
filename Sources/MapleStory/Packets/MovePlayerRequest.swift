//
//  MovePlayerRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct MovePlayerRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x26 }
    
    internal let value0: UInt8
    
    internal let value1: UInt32
    
    public let movements: [Movement]
}
