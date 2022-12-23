//
//  CheckNameRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct CheckNameRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0015 }
    
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
