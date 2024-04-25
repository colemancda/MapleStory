//
//  AllCharactersSelectRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

import Foundation

public struct AllCharactersSelectRequest: MapleStoryPacket, Decodable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0E }
    
    public let character: Character.ID
    
    public let macAddresses: String
}
