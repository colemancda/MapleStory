//
//  PlayerUpdateRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/23/22.
//

import Foundation

public struct PlayerUpdateRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .playerUpdate }
    
    public init() { }
}
