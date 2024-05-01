//
//  AllCharactersRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct AllCharactersRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { .init(client: .viewAllCharacters) }
}
