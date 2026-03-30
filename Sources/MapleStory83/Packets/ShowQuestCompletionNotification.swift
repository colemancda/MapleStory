//
//  ShowQuestCompletionNotification.swift
//

import Foundation

/// Plays the quest clear animation on the client.
public struct ShowQuestCompletionNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .questClear }

    public let questID: UInt16

    public init(questID: UInt16) {
        self.questID = questID
    }
}

extension ShowQuestCompletionNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(questID, isLittleEndian: true)
    }
}
