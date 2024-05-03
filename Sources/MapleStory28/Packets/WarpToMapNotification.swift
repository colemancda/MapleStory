//
//  WarpToMapNotification.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation
import MapleStory

public struct WarpToMapNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public typealias CharacterStats = CharacterListResponse.CharacterStats
    
    public static var opcode: ServerOpcode { .channelWarpToMap }
    
    public let channel: UInt32
    
    public let characterPortalCounter: UInt8 // 0
    
    public let isConnecting: Bool // true
    
    public let randomBytesA: UInt32
    
    public let randomBytesB: UInt32
    
    public let randomBytesC: UInt32
    
    public let randomBytesD: UInt32
    
    internal let value0: UInt8 // 0xFF
    
    internal let value1: UInt8 // 0xFF
    
    public let character: Character.Index
    
    public let stats: CharacterStats
    
    public let buddyListSize: UInt8 // 20
    
    public let mesos: UInt32
    
    public let equipSlotSize: UInt8
    
    public let useSlotSize: UInt8
    
    public let setupSlotSize: UInt8
    
    public let etcSlotSize: UInt8
    
    public let cashSlotSize: UInt8
    
    //public let timestamp: UInt64
}
