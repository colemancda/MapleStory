//
//  UpdateQuestInfoNotification.swift
//

import Foundation

/// Updates client quest info (start/progress/complete state).
///
public struct UpdateQuestInfoNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .updateQuestInfo }

    public let mode: UInt8

    public let questID: UInt16

    public let npcID: UInt32

    public let unknown: UInt32
}
