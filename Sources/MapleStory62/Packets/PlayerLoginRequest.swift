//
//  PlayerLoginPacket.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

/// Player Login
public struct PlayerLoginRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x14 }
    
    public let character: Character.ID
    
    internal let value0: UInt16
    
    public init(character: Character.ID) {
        self.character = character
        self.value0 = 0x0000
    }
}
