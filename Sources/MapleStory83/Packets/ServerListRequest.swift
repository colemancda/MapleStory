//
//  ServerListRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/27/24.
//

/// Server List Requesy
public struct ServerListRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: ClientOpcode { .serverListRequest }
    
    public init() { }
}
