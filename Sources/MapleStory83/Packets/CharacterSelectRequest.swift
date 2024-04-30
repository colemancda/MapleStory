//
//  CharacterSelectRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct CharacterSelectRequest: MapleStoryPacket, Decodable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x13 }
    
    public let character: Character.Index
    
    public let macAddresses: String
}
