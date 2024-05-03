//
//  DeleteCharacterRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

public struct DeleteCharacterRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .deleteCharacter }
    
    public let birthday: UInt32
    
    public let character: Character.Index
    
    public init(birthday: UInt32, character: Character.Index) {
        self.birthday = birthday
        self.character = character
    }
}
