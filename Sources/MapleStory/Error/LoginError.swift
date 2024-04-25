//
//  LoginError.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation

/// Login Error
public enum LoginError: UInt8, Error {
    
    case blocked            = 3
    case invalidPassword    = 4
    case notRegistered      = 5
    case systemError        = 6
    case alreadyLoggedIn    = 7
    case systemError2       = 8
    case systemError3       = 9
    /// Cannot process so many connections.
    case tooManyConnections = 10
}
