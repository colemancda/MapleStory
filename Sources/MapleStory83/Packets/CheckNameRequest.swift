//
//  CheckNameRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct CheckCharacterNameRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .checkCharacterName }
    
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
