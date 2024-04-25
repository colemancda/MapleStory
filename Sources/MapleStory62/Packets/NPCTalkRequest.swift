//
//  NPCTalkRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct NPCTalkRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0036 }
    
    public let objectID: UInt32
    
    internal let value0: UInt32
}
