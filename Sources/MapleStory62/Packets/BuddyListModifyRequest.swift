//
//  BuddyListModifyRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct BuddyListModifyRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .buddylistModify }

    /// 1 = add, 2 = accept, 3 = remove
    public let mode: UInt8

    /// Name to add (mode == 1)
    public let addName: String?

    /// Other character ID (mode == 2 or 3)
    public let otherCharacterID: UInt32?
}

extension BuddyListModifyRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.mode = try container.decode(UInt8.self)
        switch mode {
        case 1:
            self.addName = try container.decode(String.self)
            self.otherCharacterID = nil
        case 2, 3:
            self.addName = nil
            self.otherCharacterID = try container.decode(UInt32.self)
        default:
            self.addName = nil
            self.otherCharacterID = nil
        }
    }
}
