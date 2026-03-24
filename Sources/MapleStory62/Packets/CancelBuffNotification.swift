//
//  CancelBuffNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Notifies a client that a buff has been cancelled
public struct CancelBuffNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .cancelBuff }

    /// Skill ID of the buff to cancel
    public let skillID: UInt32

    /// Create cancel buff notification
    public init(skillID: UInt32) {
        self.skillID = skillID
    }
}
