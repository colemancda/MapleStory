//
//  FameResponseNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Response to giving fame
public struct FameResponseNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .fameResponse }

    /// Whether the fame was successful
    public let success: Bool

    /// New fame value
    public let newFame: UInt16

    public init(success: Bool, newFame: UInt16) {
        self.success = success
        self.newFame = newFame
    }
}
