//
//  CreateCharacterResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct CreateCharacterResponse: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .createCharacterResponse }
    
    public typealias Character = CharacterListResponse.Character
    
    public var error: Bool
    
    public var character: Character
    
    public init(error: Bool = false, character: Character) {
        self.error = error
        self.character = character
    }
}
