//
//  KillMonsterNotification.swift
//

import Foundation

/// Kill monster notification sent to clients in the map.
///
public struct KillMonsterNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .killMonster }

    public let objectID: UInt32

    /// 0 = disappear immediately, 1 = fade out, 2+ = special animation.
    public let animation: UInt8

    public let animation2: UInt8
}
