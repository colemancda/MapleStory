//
//  Gender.swift
//  
//
//  Created by Alsey Coleman Miller on 12/21/22.
//

/// Character Gender
public enum Gender: UInt8, Codable, CaseIterable, Sendable {
    
    /// Male
    case male       = 0
    
    /// Female
    case female     = 1
}
