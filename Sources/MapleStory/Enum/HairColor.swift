//
//  HairColor.swift
//
//
//  Created by Alsey Coleman Miller on 5/1/24.
//

public extension Hair {
    
    /// MapleStory Hair Color
    enum Color: UInt8, Codable, CaseIterable, Sendable {
        
        /// Black
        case black      = 0x00
        
        /// Red
        case red        = 0x01
        
        /// Orange
        case orange     = 0x02
        
        /// Blonde
        case blonde     = 0x03
        
        /// Green
        case green      = 0x04
        
        /// Blue
        case blue       = 0x05
        
        /// Purple
        case purple     = 0x06
        
        /// Brown
        case brown      = 0x07
    }
}
