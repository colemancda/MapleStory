//
//  ServerStatusResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation
import MapleStory

/// Server Status Response
///
/// Packet detailing a server status message.
public enum ServerStatusResponse: UInt16, MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: ServerOpcode { .serverStatus }
    
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
