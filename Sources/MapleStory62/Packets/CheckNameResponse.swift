//
//  CheckNameResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct CheckCharacterNameResponse: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .checkCharacterNameResponse }
    
    public let name: String
    
    public let isUsed: Bool
    
    public init(name: String, isUsed: Bool = false) {
        self.name = name
        self.isUsed = isUsed
    }
}
