//
//  QuestActionHandler.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

public struct QuestActionHandler: PacketHandler {

    public typealias Packet = MapleStory83.QuestActionRequest

    public init() { }

    public func handle<Socket: MapleStorySocket, Database: ModelStorage>(
        packet: Packet,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard var character = try await connection.character else {
            return
        }

        guard await connection.questExists(packet.questID) else {
            return
        }

        let questID = packet.questID

        switch packet.action {
        case 1: // Start quest
            guard let npcID = packet.npcID else { return }
            try await handleStart(questID: questID, npcID: npcID, character: &character, connection: connection)

        case 2: // Complete quest
            guard let npcID = packet.npcID else { return }
            let selection = packet.selection.map { UInt8($0) } ?? 0
            try await handleComplete(questID: questID, npcID: npcID, selection: selection, character: &character, connection: connection)

        case 3: // Forfeit quest
            try await handleForfeit(questID: questID, character: &character, connection: connection)

        case 4, 5: // Scripted start/end
            return

        default:
            return
        }

        try await connection.database.insert(character)

        let questData = await connection.questData(for: character.id)
        _ = questData
    }

    private func handleStart<Socket: MapleStorySocket, Database: ModelStorage>(
        questID: QuestID,
        npcID: UInt32,
        character: inout Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let requirement = await connection.questRequirement(questID: questID) else { return }
        guard requirement.canStartAt(npcID: npcID) else { return }

        let current = await connection.questState(questID, for: character.id)
        if let state = current {
            if !requirement.canRepeat(completionCount: state.completionCount) { return }
            if state.status == .started { return }
        }

        let allQuests = await connection.allQuestStates(for: character.id)
        guard requirement.canStart(character: character, questStates: allQuests) else { return }

        await connection.startQuest(questID, for: character.id)

        try await connection.send(UpdateQuestInfoNotification(
            questID: questID,
            state: .started,
            progress: ""
        ))
    }

    private func handleComplete<Socket: MapleStorySocket, Database: ModelStorage>(
        questID: QuestID,
        npcID: UInt32,
        selection: UInt8,
        character: inout Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        guard let requirement = await connection.questRequirement(questID: questID) else { return }
        guard requirement.canCompleteAt(npcID: npcID) else { return }

        let current = await connection.questState(questID, for: character.id)
        guard let state = current, state.status == .started else { return }

        let meetsProgress = await connection.questMeetsRequirements(questID, for: character)
        guard meetsProgress else { return }

        guard let reward = await connection.questReward(questID: questID) else { return }

        if reward.exp > 0 {
            try await connection.gainExp(reward.exp)
        }

        if reward.meso > 0 {
            character.meso = character.meso + reward.meso
        }

        if !reward.items.isEmpty {
            let manipulator = InventoryManipulator()
            for (itemID, quantity) in reward.items {
                guard try await manipulator.checkSpace(itemID, quantity: quantity, for: character) else { continue }
                try await manipulator.addFromDrop(itemID, quantity: quantity, to: character)
            }
        }

        let success = await connection.completeQuest(questID, for: character.id)
        guard success else { return }

        try await connection.send(ShowQuestCompletionNotification(
            questID: questID,
            selection: selection,
            expReward: reward.exp,
            mesoReward: reward.meso,
            items: reward.items
        ))

        try await connection.send(UpdateQuestInfoNotification(
            questID: questID,
            state: .completed,
            progress: ""
        ))
    }

    private func handleForfeit<Socket: MapleStorySocket, Database: ModelStorage>(
        questID: QuestID,
        character: inout Character,
        connection: MapleStoryServer<Socket, Database, ClientOpcode, ServerOpcode>.Connection
    ) async throws {
        let current = await connection.questState(questID, for: character.id)
        guard let state = current, state.status == .started else { return }

        let success = await connection.forfeitQuest(questID, for: character.id)
        guard success else { return }

        try await connection.send(UpdateQuestInfoNotification(
            questID: questID,
            state: .notStarted,
            progress: ""
        ))
    }
}
