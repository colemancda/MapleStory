//
//  Character+Quest.swift
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

public extension Character {

    /// Get quest data for database persistence
    func getQuestData() async -> CharacterQuestData {
        let quests = await QuestStateRegistry.shared.quests(for: id)
        return CharacterQuestData(characterID: id, quests: quests)
    }

    /// Load quest data from database into registry
    func loadQuestData(_ data: CharacterQuestData) async {
        for (questID, state) in data.quests {
            // Only load if not already in memory (prevents overwriting live changes)
            if await QuestStateRegistry.shared.quest(questID, for: id) == nil {
                // Need a way to set quest state directly
                // For now, we'll re-start or complete as appropriate
                if state.status == .started {
                    await QuestStateRegistry.shared.startQuest(questID, for: id)
                } else if state.status == .completed {
                    await QuestStateRegistry.shared.startQuest(questID, for: id)
                    _ = await QuestStateRegistry.shared.completeQuest(questID, for: id)
                }
            }
        }
    }
}
