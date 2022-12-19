//
//  GuestLoginRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/18/22.
//

import Foundation

/// Guest Login Request
public struct GuestLoginRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x02 }
    
    
}
