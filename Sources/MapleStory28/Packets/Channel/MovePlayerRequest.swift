//
//  MovePlayerRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation
import MapleStory

public struct MovePlayerRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .channelPlayerMovement }
    
    public let portalCount: UInt8
    
    public let x: UInt16
    
    public let y: UInt16
    
    public let movements: [Movement]
    
    internal let value0: UInt64
    
    internal let value1: UInt16
}
