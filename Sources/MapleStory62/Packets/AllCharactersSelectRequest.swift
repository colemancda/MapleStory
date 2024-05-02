//
//  AllCharactersSelectRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

import Foundation

public struct AllCharactersSelectRequest: MapleStoryPacket, Decodable, Equatable, Hashable {
    
    public static var opcode: ClientOpcode { .pickAllCharacters }
    
    public let character: Character.Index
    
    public let macAddresses: String
}
