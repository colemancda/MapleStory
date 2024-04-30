//
//  PinOperationRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct PinOperationRequest: MapleStoryPacket, Decodable, Equatable, Hashable {
    
    public static var opcode: Opcode { .init(client: .afterLogin) } //0x09
    
    public let value0: UInt8
    
    public let value1: UInt8
}
