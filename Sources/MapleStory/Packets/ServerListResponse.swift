//
//  ServerListResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation

/// Server List Response
///
/// A packet detailing a server and its channels.
public struct ServerListResponse: MapleStoryPacket, Encodable, Equatable, Hashable, Identifiable {
    
    public static var opcode: Opcode { 0x0A }
    
    public let id: UInt8
    
    public var name: String
    
    public var flags: UInt8
    
    public var eventMessage: String
    
    public var rateModifier: UInt8
    
    public var eventXP: UInt8
    
    public var rateModifier2: UInt8
    
    public var dropRate: UInt8
    
    public var value0: UInt8
    
    public var lastChannel: UInt8
    
    
    
    public var value1: UInt16
}
