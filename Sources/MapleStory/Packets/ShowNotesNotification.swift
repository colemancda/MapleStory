//
//  ShowNotesNotification.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

/// Show Notes
public struct ShowNotesNotification: MapleStoryPacket, Codable, Equatable, Hashable {
    
    public static var opcode: Opcode { 0x26 }
    
    internal let value0: UInt8 // 2
    
    public let notes: [Note]
}

public extension ShowNotesNotification {
    
    struct Note: Codable, Equatable, Hashable, Identifiable {
        
        public let id: UInt32
        
        public let from: String
        
        public let message: String
        
        public let timestamp: Date
        
        internal let value0: UInt8 // 0
    }
}
