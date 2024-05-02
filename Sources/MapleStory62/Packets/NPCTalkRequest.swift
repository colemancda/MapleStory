//
//  NPCTalkRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct NPCTalkRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .npcTalk }
    
    public let objectID: UInt32
    
    internal let value0: UInt32
}
