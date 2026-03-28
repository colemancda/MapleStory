//
//  DistributeSPRequest.swift
//

import Foundation

/// Client request to spend an SP point on a skill.
public struct DistributeSPRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .distributeSP }

    internal let value0: UInt32

    /// Skill ID to level up
    public let skillID: UInt32
}
