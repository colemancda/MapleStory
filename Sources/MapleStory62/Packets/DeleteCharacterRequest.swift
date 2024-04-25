//
//  DeleteCharacterRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct DeleteCharacterRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x17 }
    
    public let date: UInt32
    
    public let character: Character.ID
    
    public init(date: UInt32, character: Character.ID) {
        self.date = date
        self.character = character
    }
}
