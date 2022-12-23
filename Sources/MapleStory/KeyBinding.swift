//
//  KeyBinding.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct KeyBinding: Codable, Equatable, Hashable {
    
    public let type: UInt8
    
    public let action: UInt32
}
