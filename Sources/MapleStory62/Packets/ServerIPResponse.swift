//
//  ServerIPResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

import Foundation

public struct ServerIPResponse: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .serverIP }
    
    public let value0: UInt16 // 0x0000
    
    public let address: MapleStoryAddress
    
    public let character: Character.Index
    
    public let value1: UInt32

    public let value2: UInt8

    public init(address: MapleStoryAddress, character: Character.Index) {
        self.value0 = 0x0000
        self.address = address
        self.character = character
        self.value1 = 0
        self.value2 = 0
    }
}
