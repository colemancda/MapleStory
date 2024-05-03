//
//  WorldRibbon.swift
//
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

public extension World {
    
    /// World Ribbon
    enum Ribbon: UInt8, Codable, CaseIterable, Sendable {
        
        /// Normal
        case normal     = 0
        
        /// Event
        case event      = 1
        
        /// New
        case new        = 2
        
        /// Hot
        case hot        = 3
    }
}
