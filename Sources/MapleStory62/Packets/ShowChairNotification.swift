//
//  ShowChairNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Sent when a character sits in a chair
public struct ShowChairNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showChair }

    /// Character ID sitting in the chair
    public let characterID: UInt32

    /// Chair item ID
    public let itemID: UInt32

    public init(characterID: UInt32, itemID: UInt32) {
        self.characterID = characterID
        self.itemID = itemID
    }
}
