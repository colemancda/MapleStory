//
//  PicCodeStatus.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

/// PIC Code Status
public enum PicCodeStatus: UInt8, Codable, CaseIterable, Sendable {
    
    /// Register PIC
    case register   = 0
    
    /// Ask for PIC
    case enabled    = 1
    
    /// Disabled
    case disabled   = 2
}
