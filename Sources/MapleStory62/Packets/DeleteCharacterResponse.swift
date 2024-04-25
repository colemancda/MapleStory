//
//  DeleteCharacterResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct DeleteCharacterResponse: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0F }
    
    public let character: Character.ID
    
    public let state: UInt8
    
    public init(character: Character.ID, state: UInt8) {
        self.character = character
        self.state = state
    }
}
