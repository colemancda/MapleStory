//
//  UseItemEffectRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Sent when a player activates a cash item cosmetic effect.
public struct UseItemEffectRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .useItemEffect }

    /// Cash item ID to activate (0 to clear)
    public let itemID: UInt32
}
