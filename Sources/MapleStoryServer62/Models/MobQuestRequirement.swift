//
//  MobQuestRequirement.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Mob kill requirement for quests
public struct MobQuestRequirement: Codable, Equatable, Hashable, Sendable {

    /// Mob ID to kill
    public let mobID: UInt32

    /// Required count
    public let requiredCount: UInt32

    /// Create mob quest requirement
    public init(mobID: UInt32, requiredCount: UInt32) {
        self.mobID = mobID
        self.requiredCount = requiredCount
    }
}

/// Extension to QuestStateRegistry for mob kill tracking
public extension QuestStateRegistry {

    /// Record a mob kill for quest progress
    func recordMobKill(
        mobID: UInt32,
        questID: QuestID,
        characterID: Character.ID
    ) {
        // Check if this quest has this mob as a requirement
        // TODO: Load quest requirements from QuestDataCache
        // For now, just track all mob kills in progress

        let progressKey = "mob_\(mobID)"

        // Get current progress
        guard let currentState = quest(questID, for: characterID),
              currentState.status == .started else {
            return
        }

        // Increment kill count
        var currentCount = currentState.progress[progressKey] ?? 0
        currentCount += 1
        updateProgress(currentCount, forKey: progressKey, questID: questID, characterID: characterID)
    }

    /// Get mob kill progress for a quest
    func getMobKillProgress(
        mobID: UInt32,
        questID: QuestID,
        characterID: Character.ID
    ) -> UInt32 {
        guard let state = quest(questID, for: characterID) else {
            return 0
        }
        let progressKey = "mob_\(mobID)"
        return state.progress[progressKey] ?? 0
    }

    /// Check if mob kill requirement is met
    func isMobKillRequirementMet(
        mobID: UInt32,
        requiredCount: UInt32,
        questID: QuestID,
        characterID: Character.ID
    ) -> Bool {
        let currentCount = getMobKillProgress(mobID: mobID, questID: questID, characterID: characterID)
        return currentCount >= requiredCount
    }
}
