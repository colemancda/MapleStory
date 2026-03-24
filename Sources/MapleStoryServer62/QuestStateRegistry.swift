//
//  QuestStateRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// Character quest data for database persistence
public struct CharacterQuestData: Codable, Equatable, Hashable, Sendable {
    /// Character ID
    public let characterID: Character.ID

    /// Quest states
    public let quests: [QuestID: QuestState]

    /// Create character quest data
    public init(characterID: Character.ID, quests: [QuestID: QuestState] = [:]) {
        self.characterID = characterID
        self.quests = quests
    }
}

/// Registry tracking quest progress for all characters.
public actor QuestStateRegistry {

    public static let shared = QuestStateRegistry()

    /// Character ID -> Quest ID -> Quest State
    private var quests: [Character.ID: [QuestID: QuestState]] = [:]

    private init() {}

    // MARK: - Quest Management

    /// Get all quest states for a character.
    public func quests(for characterID: Character.ID) -> [QuestID: QuestState] {
        quests[characterID] ?? [:]
    }

    /// Get state for a specific quest.
    public func quest(_ questID: QuestID, for characterID: Character.ID) -> QuestState? {
        quests[characterID]?[questID]
    }

    /// Start a quest.
    public func startQuest(_ questID: QuestID, for characterID: Character.ID) {
        if quests[characterID] == nil {
            quests[characterID] = [:]
        }

        var state = QuestState(
            questID: questID,
            status: .started,
            startTime: Date()
        )
        quests[characterID]?[questID] = state
    }

    /// Update quest progress.
    public func updateProgress(
        _ progress: UInt32,
        forKey key: String,
        questID: QuestID,
        characterID: Character.ID
    ) {
        guard var state = quests[characterID]?[questID] else {
            return
        }
        state.progress[key] = progress
        quests[characterID]?[questID] = state
    }

    /// Complete a quest.
    @discardableResult
    public func completeQuest(_ questID: QuestID, for characterID: Character.ID) -> Bool {
        guard var state = quests[characterID]?[questID] else {
            return false
        }

        guard state.status == .started else {
            return false
        }

        state.status = .completed
        state.completionTime = Date()
        state.completionCount += 1
        quests[characterID]?[questID] = state
        return true
    }

    /// Forfeit a quest.
    @discardableResult
    public func forfeitQuest(_ questID: QuestID, for characterID: Character.ID) -> Bool {
        guard var state = quests[characterID]?[questID] else {
            return false
        }

        guard state.status == .started else {
            return false
        }

        state.status = .notStarted
        state.startTime = nil
        state.progress = [:]
        quests[characterID]?[questID] = state
        return true
    }

    /// Reset all quests for a character (e.g., on rebirth).
    public func resetAll(for characterID: Character.ID) {
        quests[characterID] = nil
    }

    /// Set quest state directly (for database loading).
    public func setState(_ state: QuestState, for characterID: Character.ID) {
        if quests[characterID] == nil {
            quests[characterID] = [:]
        }
        quests[characterID]?[state.questID] = state
    }

    /// Check if quest progress meets requirements.
    public func meetsRequirements(
        questID: QuestID,
        for characterID: Character.ID
    ) -> Bool {
        guard let state = quests[characterID]?[questID] else {
            return false
        }

        // Check if quest is started
        guard state.status == .started else {
            return false
        }

        // TODO: Check specific quest objectives
        // - Mob kill counts
        // - Item collection requirements
        // - Etc.

        // For now, require at least some progress
        return !state.progress.isEmpty || state.startTime != nil
    }

    /// Get all quest states as CharacterQuestData for persistence.
    public func getQuestData(for characterID: Character.ID) -> CharacterQuestData {
        let quests = quests(for: characterID)
        return CharacterQuestData(characterID: characterID, quests: quests)
    }

    /// Load quest states from database.
    public func loadQuestData(_ data: CharacterQuestData) {
        for (questID, state) in data.quests {
            setState(state, for: data.characterID)
        }
    }
}
