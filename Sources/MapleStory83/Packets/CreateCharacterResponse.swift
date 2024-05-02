//
//  CreateCharacterResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct CreateCharacterResponse: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .CreateCharacterResponse }
    
    public typealias Character = CharacterListResponse.Character
    
    public var error: Bool
    
    public var character: Character
    
    public init(error: Bool = false, character: Character) {
        self.error = error
        self.character = character
    }
}
