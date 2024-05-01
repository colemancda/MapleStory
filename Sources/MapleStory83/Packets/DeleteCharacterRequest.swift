//
//  DeleteCharacterRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct DeleteCharacterRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { .init(client: .deleteCharacter) }
    
    public let picCode: String
    
    public let character: Character.Index
    
    public init(picCode: String, character: Character.Index) {
        self.picCode = picCode
        self.character = character
    }
}
