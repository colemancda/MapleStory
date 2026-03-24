//
//  Character+Quest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStoryServer62

/// Quest-related convenience methods for Character
public extension Character {

    /// Load quest progress from database into registry
    /// Call this when player logs in
    func loadQuestData(from database: some ModelStorage) async throws {
        // TODO: Load CharacterQuestData from database
        // let questData: CharacterQuestData = try database.fetch(...)
        // await QuestStateRegistry.shared.loadQuestData(questData)
    }

    /// Save quest progress to database
    /// Call this when player logs out or periodically
    func saveQuestData(to database: some ModelStorage) async throws {
        let questData = await QuestStateRegistry.shared.getQuestData(for: id)
        // TODO: Save to database
        // try database.insert(questData)
    }
}
