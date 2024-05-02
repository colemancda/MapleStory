//
//  DeleteCharacterResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct DeleteCharacterResponse: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: ServerOpcode { .deleteCharacterResponse }
    
    public let character: Character.Index
    
    public let state: UInt8
    
    public init(character: Character.Index, state: UInt8) {
        self.character = character
        self.state = state
    }
}
