//
//  KeyBinding.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct KeyBinding: Codable, Equatable, Hashable, Sendable {
    
    public let type: UInt8
    
    public let action: UInt32
    
    public init(type: UInt8, action: UInt32) {
        self.type = type
        self.action = action
    }
}
