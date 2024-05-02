//
//  CheckNameRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct CheckCharacterNameRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: ClientOpcode { .checkCharacterName }
    
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
