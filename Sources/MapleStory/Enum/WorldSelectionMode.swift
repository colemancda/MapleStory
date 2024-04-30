//
//  WorldSelectionMode.swift
//
//
//  Created by Alsey Coleman Miller on 4/30/24.
//

import Foundation

public enum WorldSelectionMode: UInt32, Codable, CaseIterable, Sendable {
    
    case showPrompt = 0
    
    case skipPrompt = 1
}
