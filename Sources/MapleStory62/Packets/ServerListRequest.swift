//
//  ServerListRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

import MapleStory

/// Server List Requesy
public struct ServerListRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .serverListRequest }
    
    public init() { }
}
