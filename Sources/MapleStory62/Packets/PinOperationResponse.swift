//
//  PinOperationResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation

public enum PinOperationResponse: UInt8, MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .pinOperation }
    
    /// PIN was accepted.
    case success            = 0
    
    /// Register a new PIN
    case register           = 1
    
    /// Invalid pin / Reenter
    case invalid            = 2
    
    /// Connection failed due to system error
    case systemError        = 3
    
    /// Enter the pin
    case enterPin           = 4
}
