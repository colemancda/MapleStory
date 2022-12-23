//
//  DeleteCharacterResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct DeleteCharacterResponse: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0F }
    
    public let client: UInt32
    
    public let state: UInt8
    
    public init(client: UInt32, state: UInt8) {
        self.client = client
        self.state = state
    }
}
