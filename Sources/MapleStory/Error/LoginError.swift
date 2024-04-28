//
//  LoginError.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation

/// Login Error
public enum LoginError: UInt8, Codable, CaseIterable, Error {
    
    /// User deleted or blocked
    case invalidUsername            = 3
    
    /// Incorrect password
    case invalidPassword            = 4
    
    /// Not a registered ID
    case notRegistered              = 5
    
    /// System error
    case systemError                = 6
    
    /// Already logged in
    case alreadyLoggedIn            = 7
    
    /// System error
    case systemError2               = 8
    
    /// System error
    case systemError3               = 9
    
    /// Cannot process so many connections
    case tooManyConnections         = 10
    
    /// Only users older than 20 can use this channel
    case ageRequirement             = 11
    
    /// Unable to log on as master at this IP
    case unableToLogOnAsMaster      = 13
    
    /// Wrong gateway or personal info
    case wrongGatewayOrPersonalInfo = 14
    
    /// Processing request
    case processingRequest          = 15
    
    /// Please verify your account through email.
    case verifyAccountByEmail1      = 16
    
    /// Wrong gateway or personal info
    case wrongGatewayOrPersonalInfo2 = 17
    
    /// Please verify your account through email..
    case verifyAccountByEmail2      = 21
    
    /// License agreement
    case licenseAgreement           = 23
    
    /// Maple Europe notice
    case europeNotice               = 25
    
    /// Full client notice (for trial versions)
    case fullClientNotice           = 27
}
