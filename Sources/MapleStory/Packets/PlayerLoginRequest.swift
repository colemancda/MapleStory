//
//  PlayerLoginPacket.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

/// Player Login
public struct PlayerLoginRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x14 }
    
    public let client: UInt32
    
    internal let value0: UInt16
    
    public init(client: UInt32) {
        self.client = client
        self.value0 = 0x0000
    }
}
