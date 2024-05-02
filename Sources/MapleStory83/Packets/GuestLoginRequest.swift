//
//  GuestLoginRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/27/24.
//

import Foundation

/// Guest Login Request
public struct GuestLoginRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: ClientOpcode { .guestLoginRequest }
    
    internal let value: UInt16
    
    public init() {
        self.value = 0x0000
    }
}
