//
//  NPCTalkType.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public enum NPCTalkType: UInt8, Codable, CaseIterable, Sendable {
    
    /// Prev / Next Dialog
    case dialog                         = 0
    
    /// Yes / No confirmation
    case confirmation                   = 1
    
    /// Get Text
    case getText                        = 2
    
    /// Get a number
    case number                         = 3
    
    /// Simple dialog
    case simple                         = 4
    
    /// Style dialog
    case styles                         = 7
    
    /// Accept / Decline confirmation
    case accept                         = 0x0C
}
