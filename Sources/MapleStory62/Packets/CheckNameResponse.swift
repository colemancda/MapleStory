//
//  CheckNameResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
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
