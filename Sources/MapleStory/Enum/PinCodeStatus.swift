//
//  PinCodeStatus.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

/// PIN Code Status
public enum PinCodeStatus: UInt8, Codable, CaseIterable, Sendable {
    
    /// PIN was accepted.
    case success            = 0
    
    /// Register a new PIN
    case register           = 1
    
    /// Invalid pin / Reenter
    case invalid            = 2
    
    /// Connection failed due to system error
    case systemError        = 3
    
    /// Enter the pin
    case enterPin           = 4
}
