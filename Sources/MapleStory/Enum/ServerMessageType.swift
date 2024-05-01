//
//  ServerMessageType.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public enum ServerMessageType: UInt8, Codable, CaseIterable, Sendable {
    
    case notice             = 0
    case popup              = 1
    case megaphone          = 2
    case superMegaphone     = 3
    case topScrolling       = 4
    case pinkText           = 5
    case lightblueText      = 6
}
