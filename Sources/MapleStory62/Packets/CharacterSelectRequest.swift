//
//  CharacterSelectRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct CharacterSelectRequest: MapleStoryPacket, Decodable, Equatable, Hashable {
    
    public static var opcode: ClientOpcode { .characterSelect }
    
    public let character: Character.Index
    
    public let macAddresses: String
}
