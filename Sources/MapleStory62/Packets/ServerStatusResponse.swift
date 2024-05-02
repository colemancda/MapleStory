//
//  ServerStatusResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation
import MapleStory

/// Server Status Response
///
/// Packet detailing a server status message.
public struct ServerStatusResponse: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ServerOpcode { .serverStatus }
    
    public let status: Channel.Status
    
    public init(status: Channel.Status) {
        self.status = status
    }
}
