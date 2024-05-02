//
//  PlayerHintNotification.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct PlayerHintNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .playerHint }
    
    public var hint: String
    
    public var width: UInt16
    
    public var height: UInt16
    
    internal let value0: UInt8 // 1
    
    public init(
        hint: String,
        width: UInt16,
        height: UInt16
    ) {
        self.hint = hint
        self.width = width
        self.height = height
        self.value0 = 1
    }
}
