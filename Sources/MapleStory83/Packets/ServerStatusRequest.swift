//
//  ServerStatusRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public struct ServerStatusRequest: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: ClientOpcode { .serverStatusRequest }
    
    public let world: UInt8
    
    public let channel: UInt8
    
    public init(world: UInt8, channel: UInt8) {
        self.world = world
        self.channel = channel
    }
}
