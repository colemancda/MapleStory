//
//  AllCharactersRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

import Foundation

public struct AllCharactersRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: ClientOpcode { .viewAllCharacters }
}
