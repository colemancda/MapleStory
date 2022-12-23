//
//  CreateCharacterResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct CreateCharacterResponse: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0E }
    
    public typealias Character = CharacterListResponse.Character
    
    public var didCreate: Bool
    
    public var character: Character
    
    public init(didCreate: Bool, character: Character) {
        self.didCreate = didCreate
        self.character = character
    }
}
