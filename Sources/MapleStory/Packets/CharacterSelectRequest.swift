//
//  CharacterSelectRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct CharacterSelectRequest: MapleStoryPacket, Decodable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x13 }
    
    public let client: UInt32
    
    public let macAddresses: String
}
