//
//  ServerStatusRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

import Foundation

public struct ServerStatusRequest: MapleStoryPacket, Decodable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x06 }
    
    public let world: UInt8
    
    public let channel: UInt8
    
    public init(world: UInt8, channel: UInt8) {
        self.world = world
        self.channel = channel
    }
}
