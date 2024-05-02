//
//  AllCharactersSelectRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct AllCharactersSelectRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .pickAllCharacters }
    
    public let character: Character.Index
    
    public let macAddresses: String
}
