//
//  UpdatePartyMemberHPNotification.swift
//

import Foundation

/// Updates a party member's HP display.
///
public struct UpdatePartyMemberHPNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .updatePartyMemberHP }

    public let characterID: UInt32

    public let currentHP: UInt32

    public let maxHP: UInt32
}
