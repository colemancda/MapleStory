//
//  PinOperationRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation

public struct PinOperationRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .afterLogin }
    
    public let value0: UInt8
    
    public let value1: UInt8
}
