//
//  ServerIPResponse.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation
import MapleStory

public struct ServerIPResponse: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .loginCharacterMigrate }
    
    public let value0: UInt16 // 0x0000
    
    public let address: MapleStoryAddress
    
    public let character: Character.Index
    
    public let value1: UInt8 // 1
    
    public let value2: UInt32 // 1
    
    public init(address: MapleStoryAddress, character: Character.Index) {
        self.value0 = 0x00
        self.address = address
        self.character = character
        self.value1 = UInt8(0) | UInt8(1<<0)
        self.value2 = 0x01
    }
}
