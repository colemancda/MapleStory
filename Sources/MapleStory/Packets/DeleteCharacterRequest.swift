//
//  DeleteCharacterRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct DeleteCharacterRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x17 }
    
    public let date: UInt32
    
    public let client: UInt32
    
    public init(date: UInt32, client: UInt32) {
        self.date = date
        self.client = client
    }
}
