//
//  NotifyJobChangeNotification.swift
//

import Foundation

/// Broadcast job advancement message to guild or family.
///
public struct NotifyJobChangeNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .notifyJobChange }

    /// 0 = guild, 1 = family.
    public let type: UInt8

    public let jobID: UInt32

    public let characterName: String
}
