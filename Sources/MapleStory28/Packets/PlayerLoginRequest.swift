//
//  PlayerLoginPacket.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

/// Player Login
public struct PlayerLoginRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .channelPlayerLoad }
    
    public let character: Character.Index
    
    internal let value0: UInt16
    
    public init(character: Character.Index) {
        self.character = character
        self.value0 = 0x0000
    }
}
