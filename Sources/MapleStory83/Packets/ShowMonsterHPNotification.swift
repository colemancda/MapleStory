//
//  ShowMonsterHPNotification.swift
//

import Foundation

/// Shows the HP percentage bar for a monster.
///
public struct ShowMonsterHPNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showMonsterHP }

    public let objectID: UInt32

    public let remainingHPPercent: UInt8
}
