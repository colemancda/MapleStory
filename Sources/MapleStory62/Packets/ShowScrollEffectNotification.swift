//
//  ShowScrollEffectNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Result of using a scroll on equipment
public struct ShowScrollEffectNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showScrollEffect }

    /// The character who used the scroll
    public let characterID: UInt32

    /// Whether the scroll succeeded (0 = success, 1 = no effect, 2 = destroyed)
    public let result: ScrollResult

    /// Position of the equipment
    public let position: Int16

    public init(characterID: UInt32, result: ScrollResult, position: Int16) {
        self.characterID = characterID
        self.result = result
        self.position = position
    }

    /// Scroll result type
    public enum ScrollResult: UInt8, Codable, Equatable, Hashable, Sendable {
        case success = 0
        case failure = 1      // No effect but not destroyed
        case destroyed = 2    // Item destroyed
    }
}
