//
//  AllCharactersRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

public struct AllCharactersRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .viewAllCharacters }
}
