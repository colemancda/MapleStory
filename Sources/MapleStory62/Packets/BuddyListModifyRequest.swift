//
//  BuddyListModifyRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Buddy list modification request packet.
/// Based on BuddylistModifyHandler.java
public struct BuddyListModifyRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .buddylistModify }

    /// Operation mode:
    /// - 1: Add buddy by name
    /// - 2: Accept pending buddy request
    /// - 3: Remove buddy
    public let mode: Mode

    /// Name to add (mode == 1)
    public let addName: String?
    
    /// Other character ID (mode == 2 or 3)
    public let otherCharacterID: UInt32?
}

// MARK: - Mode Enum

public extension BuddyListModifyRequest {

    enum Mode: UInt8, CaseIterable, Sendable, Codable {
        case add = 1
        case accept = 2
        case remove = 3
    }
}

extension BuddyListModifyRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.mode = try container.decode(Mode.self)
        switch mode {
        case .add:
            self.addName = try container.decode(String.self)
            self.otherCharacterID = nil
        case .accept, .remove:
            self.addName = nil
            self.otherCharacterID = try container.decode(UInt32.self)
        }
    }
}
