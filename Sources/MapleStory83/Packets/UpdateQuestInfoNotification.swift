//
//  UpdateQuestInfoNotification.swift
//

import Foundation
import MapleStory

public struct UpdateQuestInfoNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .updateQuestInfo }

    public let questID: UInt16

    public let state: UInt8

    public let progress: String

    public init(questID: QuestID, state: QuestStatus, progress: String = "") {
        self.questID = questID
        self.state = state.rawValue
        self.progress = progress
    }
}
