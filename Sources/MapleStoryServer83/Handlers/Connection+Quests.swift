//
//  Connection+Quests.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

extension MapleStoryServer.Connection
where ClientOpcode == MapleStory83.ClientOpcode, ServerOpcode == MapleStory83.ServerOpcode {

    // MARK: - Quest State

    func questState(_ questID: QuestID, for characterID: Character.ID) async -> QuestState? {
        await QuestStateRegistry.shared.quest(questID, for: characterID)
    }

    func allQuestStates(for characterID: Character.ID) async -> [QuestID: QuestState] {
        await QuestStateRegistry.shared.quests(for: characterID)
    }

    func startQuest(_ questID: QuestID, for characterID: Character.ID) async {
        await QuestStateRegistry.shared.startQuest(questID, for: characterID)
    }

    func completeQuest(_ questID: QuestID, for characterID: Character.ID) async -> Bool {
        await QuestStateRegistry.shared.completeQuest(questID, for: characterID)
    }

    func forfeitQuest(_ questID: QuestID, for characterID: Character.ID) async -> Bool {
        await QuestStateRegistry.shared.forfeitQuest(questID, for: characterID)
    }

    func questMeetsRequirements(_ questID: QuestID, for character: MapleStory.Character) async -> Bool {
        await QuestStateRegistry.shared.meetsRequirements(questID: questID, for: character)
    }

    func questData(for characterID: Character.ID) async -> CharacterQuestData {
        await QuestStateRegistry.shared.getQuestData(for: characterID)
    }

    // MARK: - Quest Data (WZ)

    func questExists(_ questID: QuestID) async -> Bool {
        await QuestDataCache.shared.exists(questID)
    }

    func questRequirement(questID: QuestID) async -> WzQuestRequirement? {
        await QuestDataCache.shared.requirement(questID: questID)
    }

    func questReward(questID: QuestID) async -> WzQuestReward? {
        await QuestDataCache.shared.reward(questID: questID)
    }
}
