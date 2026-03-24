//
//  NPCTalkDialogButtons.swift
//  
//
//  Created by Alsey Coleman Miller on 12/22/22.
//

import Foundation

public struct NPCTalkDialogButtons: OptionSet, Equatable, Hashable, Codable, Sendable {
    
    public var rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

public extension NPCTalkDialogButtons {

    /// Show "Next" button only (no previous).
    /// Encodes as little-endian UInt16: [hasPrev=0x00, hasNext=0x01]
    static let next = NPCTalkDialogButtons(rawValue: 0x0100)

    /// Show "Back" button only (no next).
    /// Encodes as little-endian UInt16: [hasPrev=0x01, hasNext=0x00]
    static let previous = NPCTalkDialogButtons(rawValue: 0x0001)
}
