//
//  ServerListRerequest.swift
//
//
//  Created by Alsey Coleman Miller on 5/4/24.
//

import Foundation
import MapleStory

/// Server List Request
public struct ServerListRerequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .serverListRerequest }
    
    public init() { }
}
