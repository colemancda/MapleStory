//
//  PlayerUpdateRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/23/22.
//

import Foundation

public struct PlayerUpdateRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0xC0 }
    
    public init() { }
}
