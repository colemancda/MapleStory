//
//  CharacterListResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

import Foundation

public struct CharacterListResponse: MapleStoryPacket, Encodable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x05 }
    
    internal let value0: UInt8
    
    public let characters: [Character]
    
    public let maxCharacters: UInt8
}

public extension CharacterListResponse {
    
    struct Character: Encodable, Equatable, Hashable {
        
        public let id: UInt32
        
        public let name: CharacterName
        
        public let gender: Gender
        
        public let skinColor: SkinColor
        
        public let face: UInt32
        
        public let hair: UInt32
        
        public let value0: UInt64
        
        public let value1: UInt64
        
        public let value2: UInt64
        
        public let level: UInt8
        
        
        public let isWorldRankEnabled: Bool
        
        public let worldRank: UInt32?
        
        public let rankMove: UInt32?
        
        public let jobRank: UInt32?
        
        public let jobRankMove: UInt32?
    }
}
