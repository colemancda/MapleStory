//
//  PinOperationRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation

public struct PinOperationRequest: MapleStoryPacket, Decodable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x09 }
    
    public let value0: UInt8
    
    public let value1: UInt8
}
