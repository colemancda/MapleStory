//
//  ServerStatusResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation

/// Server Status Response
///
/// Packet detailing a server status message.
public enum ServerStatusResponse: UInt16, MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x03 }
    
    /// Normal
    case normal         = 0
    
    /// High Usage
    case highUsage      = 1
    
    /// Full
    case full           = 2
}

public extension ServerStatusResponse {
    
    init(_ status: Channel.Status) {
        switch status {
        case .normal:
            self = .normal
        case .highUsage:
            self = .highUsage
        case .full:
            self = .full
        }
    }
}
