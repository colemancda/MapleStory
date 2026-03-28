//
//  SkillCooldownNotification.swift
//

import Foundation

/// Sets a skill cooldown timer on the client.
///
public struct SkillCooldownNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .cooldown }

    public let skillID: UInt32

    /// Cooldown duration in seconds.
    public let time: UInt16
}
