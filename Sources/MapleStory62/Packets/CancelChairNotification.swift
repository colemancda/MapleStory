//
//  CancelChairNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Sent when a character stands up from a chair
public struct CancelChairNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .cancelChair }

    /// Character ID standing up
    public let characterID: UInt32

    public init(characterID: UInt32) {
        self.characterID = characterID
    }
}
