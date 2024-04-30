//
//  CheckNameResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct CheckNameResponse: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0D }
    
    public let name: String
    
    public let isUsed: Bool
    
    public init(name: String, isUsed: Bool = false) {
        self.name = name
        self.isUsed = isUsed
    }
}
