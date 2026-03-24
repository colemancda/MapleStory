//
//  QuestDataCache.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// In-memory cache of quest data.
public actor QuestDataCache {

    public static let shared = QuestDataCache()

    private var requirements: [QuestID: QuestRequirement] = [:]
    private var rewards: [QuestID: QuestReward] = [:]

    private init() {}

    /// Register quest data.
    public func registerQuest(
        id: QuestID,
        requirement: QuestRequirement,
        reward: QuestReward
    ) {
        requirements[id] = requirement
        rewards[id] = reward
    }

    /// Get quest requirements.
    public func requirement(questID: QuestID) -> QuestRequirement? {
        requirements[questID]
    }

    /// Get quest rewards.
    public func reward(questID: QuestID) -> QuestReward? {
        rewards[questID]
    }

    /// Check if quest exists.
    public func exists(_ questID: QuestID) -> Bool {
        requirements[questID] != nil
    }

    /// Number of registered quests.
    public var count: Int { requirements.count }
}
