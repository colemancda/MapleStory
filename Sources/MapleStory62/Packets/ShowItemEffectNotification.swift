//
//  ShowItemEffectNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Broadcast to all other players on the map when a character activates a cash item visual effect.
public struct ShowItemEffectNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showItemEffect }

    public let characterID: UInt32

    /// Cash item ID (0 to clear)
    public let itemID: UInt32

    public init(characterID: UInt32, itemID: UInt32) {
        self.characterID = characterID
        self.itemID = itemID
    }
}
