//
//  ServerListRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/27/24.
//

/// Server List Requesy
public struct ServerListRequest: MapleStoryPacket, Decodable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x0B }
    
    public init() { }
}
