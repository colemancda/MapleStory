//
//  ChannelStatus.swift
//  
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation

public extension Channel {
    
    /// Channel Status
    enum Status: UInt8, Codable, CaseIterable, Sendable {
        
        /// Normal
        case normal         = 0
        
        /// High Usage
        case highUsage      = 1
        
        /// Full
        case full           = 2
    }
}
