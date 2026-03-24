//
//  QuestActionHandler.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory
import MapleStory62
import MapleStoryServer

public struct QuestActionHandler: PacketHandler {

    public typealias Packet = MapleStory62.QuestActionRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else {
            return
        }

        // Check if quest exists
        guard await QuestDataCache.shared.exists(packet.questID) else {
            return // Quest doesn't exist
        }

        let questID = packet.questID

        switch packet.action {
        case 1: // Start quest
            try await handleStart(questID: questID, character: &character, connection: connection)

        case 2: // Complete quest
            try await handleComplete(questID: questID, character: &character, connection: connection)

        case 3: // Forfeit quest
            try await handleForfeit(questID: questID, character: &character, connection: connection)

        case 4, 5: // Scripted start/end (handled by NPC scripts)
            return

        default:
            return // Invalid action
        }

        // Save character
        try await connection.database.insert(character)
    }

    // MARK: - Start Quest

    private func handleStart<Socket: MapleStorySocket, Database: ModelStorage>(
        questID: QuestID,
        character: inout Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Check if already completed or started
        let current = await QuestStateRegistry.shared.quest(questID, for: character.id)
        if let state = current, state.status != .notStarted {
            return // Already started or completed
        }

        // Check requirements
        guard let requirement = await QuestDataCache.shared.requirement(questID: questID) else {
            return
        }

        let allQuests = await QuestStateRegistry.shared.quests(for: character.id)
        guard requirement.canStart(character: character, questStates: allQuests) else {
            return // Doesn't meet requirements
        }

        // Start quest
        await QuestStateRegistry.shared.startQuest(questID, for: character.id)

        // TODO: Send quest started notification to client
    }

    // MARK: - Complete Quest

    private func handleComplete<Socket: MapleStorySocket, Database: ModelStorage>(
        questID: QuestID,
        character: inout Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Check if quest is started
        let current = await QuestStateRegistry.shared.quest(questID, for: character.id)
        guard let state = current, state.status == .started else {
            return // Quest not started
        }

        // Get quest rewards
        guard let reward = await QuestDataCache.shared.reward(questID: questID) else {
            return
        }

        // Grant EXP reward
        if reward.exp > 0 {
            try await connection.gainExp(reward.exp)
        }

        // Grant meso reward
        if reward.meso > 0 {
            character.meso = character.meso + reward.meso
        }

        // Grant item rewards
        if !reward.items.isEmpty {
            let manipulator = InventoryManipulator()
            for (itemID, quantity) in reward.items {
                // Check inventory space
                guard try await manipulator.checkSpace(itemID, quantity: quantity, for: character) else {
                    continue // Skip if no space
                }

                // Add item
                try await manipulator.addFromDrop(itemID, quantity: quantity, to: character)
            }
        }

        // Mark quest as completed
        let success = await QuestStateRegistry.shared.completeQuest(questID, for: character.id)
        guard success else {
            return
        }

        // TODO: Send quest completed notification to client
    }

    // MARK: - Forfeit Quest

    private func handleForfeit<Socket: MapleStorySocket, Database: ModelStorage>(
        questID: QuestID,
        character: inout Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        // Check if quest is started
        let current = await QuestStateRegistry.shared.quest(questID, for: character.id)
        guard let state = current, state.status == .started else {
            return // Quest not started
        }

        // Forfeit quest
        let success = await QuestStateRegistry.shared.forfeitQuest(questID, for: character.id)
        guard success else {
            return
        }

        // TODO: Send quest forfeited notification to client
    }
}
