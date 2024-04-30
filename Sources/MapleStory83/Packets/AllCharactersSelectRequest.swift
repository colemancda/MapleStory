//
//  AllCharactersSelectRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct AllCharactersSelectRequest: MapleStoryPacket, Decodable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0E }
    
    public let character: Character.Index
    
    public let macAddresses: String
}
