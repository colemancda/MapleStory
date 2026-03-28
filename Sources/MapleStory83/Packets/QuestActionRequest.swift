//
//  QuestActionRequest.swift
//

import Foundation

public struct QuestActionRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .questAction }

    /// 1=start, 2=complete, 3=forfeit, 4=scripted start, 5=scripted end
    public let action: UInt8

    /// Quest ID
    public let questID: UInt16

    /// NPC that triggered the quest action (present for actions 1, 2, 4, 5)
    public let npcID: UInt32?

    /// Reward selection index (present on completion when extra bytes available)
    public let selection: UInt32?
}

extension QuestActionRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.action = try container.decode(UInt8.self)
        self.questID = try container.decode(UInt16.self)
        if container.remainingBytes >= 8 {
            self.npcID = try container.decode(UInt32.self)
            let _ = try container.decode(UInt32.self) // unknown
        } else {
            self.npcID = nil
        }
        if container.remainingBytes >= 4 {
            self.selection = try container.decode(UInt32.self)
        } else {
            self.selection = nil
        }
    }
}
