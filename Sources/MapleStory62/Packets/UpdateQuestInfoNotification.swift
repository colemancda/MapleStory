//
//  UpdateQuestInfoNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Updates quest progress/status on client
public struct UpdateQuestInfoNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .updateQuestInfo }

    /// Quest ID
    public let questID: UInt16

    /// Quest state (0 = not started, 1 = started, 2 = completed)
    public let state: UInt8

    /// Quest progress data
    public let progress: String

    /// Create quest update notification
    public init(questID: UInt16, state: QuestStatus, progress: String = "") {
        self.questID = questID
        self.state = state.rawValue
        self.progress = progress
    }
}
