//
//  SpawnNPCNotification.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct SpawnNPCRequestControllerNotification: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0xC4 }
    
    internal let value0: UInt8
    
    public let objectId: UInt32
    
    public let id: UInt32
    
    public let x: UInt16
    
    public let cy: UInt16
    
    public let f: Bool
    
    public let fh: UInt16
    
    public let rx0: UInt16
    
    public let rx1: UInt16
    
    public let minimap: Bool
}
