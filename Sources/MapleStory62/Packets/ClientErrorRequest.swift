//
//  ClientErrorRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 5/4/24.
//

import Foundation
import MapleStory

public struct ClientErrorRequest: MapleStoryPacket, Equatable, Hashable, Codable, Sendable {
    
    public static var opcode: ClientOpcode { .clientError }
    
    public let error: Bool
    
    public let value0: UInt32
    
    public let value1: UInt32
}
