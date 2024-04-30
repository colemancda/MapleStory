//
//  DeleteCharacterRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct DeleteCharacterRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x17 }
    
    public let date: UInt32
    
    public let character: Character.Index
    
    public init(date: UInt32, character: Character.Index) {
        self.date = date
        self.character = character
    }
}
