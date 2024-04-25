//
//  CharacterSelectRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct CharacterSelectRequest: MapleStoryPacket, Decodable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x13 }
    
    public let character: Character.ID
    
    public let macAddresses: String
}
