//
//  Connection+Social.swift
//

import Foundation
import CoreModel
import MapleStory
import MapleStory83
import MapleStoryServer

extension MapleStoryServer.Connection
where ClientOpcode == MapleStory83.ClientOpcode, ServerOpcode == MapleStory83.ServerOpcode {

    // MARK: - Party

    func party(for characterID: Character.ID) async throws -> PartyEntity? {
        try await PartyRegistry.shared.party(for: characterID, in: database)
    }

    func party(by partyID: PartyID) async throws -> PartyEntity? {
        try await PartyRegistry.shared.party(by: partyID, in: database)
    }

    func partyMembers(_ partyID: PartyEntity.ID) async throws -> [PartyMemberEntity] {
        try await PartyRegistry.shared.loadPartyMembers(partyID, from: database)
    }

    func createParty(
        leaderID: Character.ID,
        leaderName: CharacterName,
        leaderJob: Job,
        leaderLevel: UInt16,
        channel: UInt8,
        map: Map.ID
    ) async throws -> PartyEntity {
        try await PartyRegistry.shared.createParty(
            leaderID: leaderID,
            leaderName: leaderName,
            leaderJob: leaderJob,
            leaderLevel: leaderLevel,
            channel: channel,
            map: map,
            in: database
        )
    }

    @discardableResult
    func addPartyMember(
        _ memberID: Character.ID,
        name: CharacterName,
        job: Job,
        level: UInt16,
        channel: UInt8,
        map: Map.ID,
        to partyID: PartyEntity.ID
    ) async throws -> Bool {
        try await PartyRegistry.shared.addMember(
            memberID,
            name: name,
            job: job,
            level: level,
            channel: channel,
            map: map,
            to: partyID,
            in: database
        )
    }

    @discardableResult
    func removePartyMember(_ characterID: Character.ID, from partyID: PartyEntity.ID) async throws -> Bool {
        try await PartyRegistry.shared.removeMember(characterID, from: partyID, in: database)
    }

    @discardableResult
    func transferPartyLeadership(_ partyID: PartyEntity.ID, to characterID: Character.ID) async throws -> Bool {
        try await PartyRegistry.shared.transferLeadership(partyID, to: characterID, in: database)
    }

    func loadParty(_ partyID: PartyEntity.ID) async throws -> PartyEntity? {
        try await PartyRegistry.shared.loadParty(partyID, from: database)
    }

    func disbandParty(_ partyID: PartyEntity.ID) async throws {
        try await PartyRegistry.shared.disbandParty(partyID, in: database)
    }

    // MARK: - Guild

    func guild(for characterID: Character.ID) async throws -> GuildEntity? {
        try await GuildRegistry.shared.guild(for: characterID, in: database)
    }

    func guildMembers(_ guildID: GuildEntity.ID) async throws -> [GuildMemberEntity] {
        try await GuildRegistry.shared.loadGuildMembers(guildID, from: database)
    }

    func createGuild(name: GuildName, leaderID: Character.ID, leaderName: CharacterName) async throws -> GuildEntity {
        try await GuildRegistry.shared.createGuild(name: name, leaderID: leaderID, leaderName: leaderName, in: database)
    }

    @discardableResult
    func removeGuildMember(_ characterID: Character.ID, from guildID: GuildEntity.ID) async throws -> Bool {
        try await GuildRegistry.shared.removeMember(characterID, from: guildID, in: database)
    }

    @discardableResult
    func updateGuildMemberRank(_ characterID: Character.ID, rank: GuildRank) async throws -> Bool {
        try await GuildRegistry.shared.updateMemberRank(characterID, rank: rank, in: database)
    }

    func disbandGuild(_ guildID: GuildEntity.ID) async throws {
        try await GuildRegistry.shared.disbandGuild(guildID, in: database)
    }

    // MARK: - Buddy List

    func isBuddyListFull(_ characterID: Character.ID, capacity: UInt8) async throws -> Bool {
        try await BuddyListRegistry.shared.isFull(characterID, capacity: capacity, in: database)
    }

    func buddyListContains(buddyID: Character.Index, in characterID: Character.ID) async throws -> Bool {
        try await BuddyListRegistry.shared.contains(buddyID: buddyID, in: characterID, database: database)
    }

    @discardableResult
    func addBuddy(_ buddy: Buddy, to characterID: Character.ID) async throws -> Bool {
        try await BuddyListRegistry.shared.addBuddy(buddy, to: characterID, in: database)
    }

    @discardableResult
    func removeBuddy(buddyID: Character.Index, from characterID: Character.ID) async throws -> Bool {
        try await BuddyListRegistry.shared.removeBuddy(buddyID: buddyID, from: characterID, in: database)
    }

    func addPendingBuddyRequest(from fromID: Character.Index, fromName: CharacterName, to toID: Character.ID) async -> Bool {
        await BuddyListRegistry.shared.addPendingRequest(from: fromID, fromName: fromName, to: toID)
    }

    func removePendingBuddyRequest(from fromID: Character.Index, to toID: Character.ID) async -> Bool {
        await BuddyListRegistry.shared.removePendingRequest(from: fromID, to: toID)
    }

    @discardableResult
    func updateBuddyPending(buddyID: Character.Index, for characterID: Character.ID, pending: Bool) async throws -> Bool {
        try await BuddyListRegistry.shared.updateBuddyPending(buddyID: buddyID, for: characterID, pending: pending, in: database)
    }

    func buddyListNotification(for characterID: Character.ID) async throws -> [BuddyListNotification.Buddy] {
        try await BuddyListRegistry.shared.buddyListNotification(for: characterID, in: database)
    }

    // MARK: - BBS

    func bbsListThreads(guildID: GuildEntity.ID) async -> [BBSThread] {
        await BBSRegistry.shared.listThreads(guildID: guildID)
    }

    func bbsThread(localID: UInt32, guildID: GuildEntity.ID) async -> BBSThread? {
        await BBSRegistry.shared.thread(localID: localID, guildID: guildID)
    }

    func bbsReplies(localID: UInt32, guildID: GuildEntity.ID) async -> [BBSReply] {
        await BBSRegistry.shared.replies(localID: localID, guildID: guildID)
    }

    func bbsCreateThread(
        guildID: GuildEntity.ID,
        posterCharacterID: UInt32,
        notice: Bool,
        title: String,
        body: String,
        icon: UInt32
    ) async {
        await BBSRegistry.shared.createThread(
            guildID: guildID,
            posterCharacterID: posterCharacterID,
            notice: notice,
            title: title,
            body: body,
            icon: icon
        )
    }

    func bbsEditThread(localID: UInt32, guildID: GuildEntity.ID, title: String, body: String, icon: UInt32) async {
        await BBSRegistry.shared.editThread(localID: localID, guildID: guildID, title: title, body: body, icon: icon)
    }

    func bbsDeleteThread(localID: UInt32, guildID: GuildEntity.ID) async {
        await BBSRegistry.shared.deleteThread(localID: localID, guildID: guildID)
    }

    func bbsCreateReply(localID: UInt32, guildID: GuildEntity.ID, posterCharacterID: UInt32, body: String) async {
        await BBSRegistry.shared.createReply(localID: localID, guildID: guildID, posterCharacterID: posterCharacterID, body: body)
    }

    func bbsDeleteReply(replyID: UInt32, guildID: GuildEntity.ID) async {
        await BBSRegistry.shared.deleteReply(replyID: replyID, guildID: guildID)
    }
}
