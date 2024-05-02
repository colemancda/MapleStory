//
//  DeleteCharacterRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct DeleteCharacterRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .deleteCharacter }
    
    public let date: UInt32
    
    public let character: Character.Index
    
    public init(date: UInt32, character: Character.Index) {
        self.date = date
        self.character = character
    }
}
