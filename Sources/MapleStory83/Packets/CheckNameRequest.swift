//
//  CheckNameRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct CheckNameRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0015 }
    
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
