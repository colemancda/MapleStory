//
//  PlayerDCRequest.swift
//
//
//  Created by Alsey Coleman Miller on 5/4/24.
//

import MapleStory

/// Server List Requesy
public struct PlayerDCRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .playerDC }
    
    public init() { }
}
