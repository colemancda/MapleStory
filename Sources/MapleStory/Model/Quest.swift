//
//  Quest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// Quest ID
public typealias QuestID = UInt16

/// Quest status
public enum QuestStatus: UInt8, Codable, Equatable, Hashable, Sendable {
    case notStarted = 0
    case started = 1
    case completed = 2
}

/// Quest completion state for a character
public struct QuestState: Codable, Equatable, Hashable, Sendable {

    /// Quest ID
    public let questID: QuestID

    /// Current status
    public var status: QuestStatus

    /// Time when quest was started
    public var startTime: Date?

    /// Time when quest was completed
    public var completionTime: Date?

    /// Number of times completed (for repeatable quests)
    public var completionCount: UInt8

    /// Quest-specific data (mob kills, item collection, etc.)
    public var progress: [String: UInt32] = [:]

    /// Create quest state
    public init(
        questID: QuestID,
        status: QuestStatus = .notStarted,
        startTime: Date? = nil,
        completionTime: Date? = nil,
        completionCount: UInt8 = 0
    ) {
        self.questID = questID
        self.status = status
        self.startTime = startTime
        self.completionTime = completionTime
        self.completionCount = completionCount
    }
}

/// Quest reward
public struct QuestReward: Codable, Equatable, Hashable, Sendable {

    /// EXP reward
    public let exp: UInt32

    /// Meso reward
    public let meso: UInt32

    /// Item rewards (item ID -> quantity)
    public let items: [UInt32: UInt16]

    /// Job-specific rewards
    public let job: UInt16?

    /// Create quest reward
    public init(
        exp: UInt32 = 0,
        meso: UInt32 = 0,
        items: [UInt32: UInt16] = [:],
        job: UInt16? = nil
    ) {
        self.exp = exp
        self.meso = meso
        self.items = items
        self.job = job
    }
}

/// Quest requirement
public struct QuestRequirement: Codable, Equatable, Hashable, Sendable {

    /// Minimum level
    public let minLevel: UInt8

    /// Maximum level
    public let maxLevel: UInt8

    /// Required job (0 = any)
    public let job: UInt16?

    /// Required quests (quest ID -> completion count)
    public let completedQuests: [QuestID: UInt8]

    /// NPCs that can start this quest
    public let startNPCs: Set<UInt32>

    /// NPCs that can complete this quest
    public let endNPCs: Set<UInt32>

    /// Is this quest repeatable?
    public let repeatable: Bool

    /// Create quest requirement
    public init(
        minLevel: UInt8 = 0,
        maxLevel: UInt8 = 200,
        job: UInt16? = nil,
        completedQuests: [QuestID: UInt8] = [:],
        startNPCs: Set<UInt32> = [],
        endNPCs: Set<UInt32> = [],
        repeatable: Bool = false
    ) {
        self.minLevel = minLevel
        self.maxLevel = maxLevel
        self.job = job
        self.completedQuests = completedQuests
        self.startNPCs = startNPCs
        self.endNPCs = endNPCs
        self.repeatable = repeatable
    }

    /// Check if character meets requirements
    public func canStart(character: Character, questStates: [QuestID: QuestState]) -> Bool {
        // Check level
        guard character.level >= UInt16(minLevel) && character.level <= UInt16(maxLevel) else {
            return false
        }

        // Check job
        if let requiredJob = job {
            // TODO: Check job compatibility
        }

        // Check completed quests
        for (questID, requiredCount) in completedQuests {
            if let state = questStates[questID] {
                if state.completionCount < requiredCount {
                    return false
                }
            } else {
                return false
            }
        }

        return true
    }

    /// Check if NPC can start this quest
    public func canStartAt(npcID: UInt32) -> Bool {
        return startNPCs.isEmpty || startNPCs.contains(npcID)
    }

    /// Check if NPC can complete this quest
    public func canCompleteAt(npcID: UInt32) -> Bool {
        return endNPCs.isEmpty || endNPCs.contains(npcID)
    }

    /// Check if quest can be repeated
    public func canRepeat(completionCount: UInt8) -> Bool {
        return repeatable || completionCount == 0
    }
}
