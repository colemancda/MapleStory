//
//  PartyRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// Registry for managing parties
public actor PartyRegistry {

    public static let shared = PartyRegistry()

    private var parties: [PartyID: Party] = [:]

    /// Next party ID
    private var nextPartyID: PartyID = 1000

    private init() {}

    // MARK: - Party Management

    /// Create a new party
    public func createParty(leaderID: Character.ID, leaderName: CharacterName, leaderJob: Job, leaderLevel: UInt16, channel: UInt8, map: Map.ID) -> Party {
        let partyID = nextPartyID
        nextPartyID += 1

        let member = PartyMember(
            characterID: leaderID,
            characterName: leaderName,
            job: leaderJob,
            level: leaderLevel,
            channel: channel,
            map: map,
            status: .online
        )

        let party = Party(
            id: partyID,
            leaderID: leaderID,
            members: [leaderID: member]
        )

        parties[partyID] = party
        return party
    }

    /// Get party by ID
    public func party(_ partyID: PartyID) -> Party? {
        return parties[partyID]
    }

    /// Get party for a character
    public func party(for characterID: Character.ID) -> Party? {
        for party in parties.values {
            if party.members[characterID] != nil {
                return party
            }
        }
        return nil
    }

    /// Add member to party
    public func addMember(
        _ characterID: Character.ID,
        name: CharacterName,
        job: Job,
        level: UInt16,
        channel: UInt8,
        map: Map.ID,
        to partyID: PartyID
    ) -> Bool {
        guard var party = parties[partyID] else { return false }
        guard party.memberCount < 6 else { return false }

        let member = PartyMember(
            characterID: characterID,
            characterName: name,
            job: job,
            level: level,
            channel: channel,
            map: map,
            status: .online
        )

        party.members[characterID] = member
        parties[partyID] = party
        return true
    }

    /// Remove member from party
    @discardableResult
    public func removeMember(_ characterID: Character.ID, from partyID: PartyID) -> Bool {
        guard var party = parties[partyID] else { return false }
        guard party.members[characterID] != nil else { return false }

        party.members.removeValue(forKey: characterID)

        // Check if party should be disbanded (only leader left)
        if party.members.count == 0 {
            parties.removeValue(forKey: partyID)
        } else if party.leaderID == characterID {
            // Transfer leadership to next member
            if let newLeader = party.members.keys.first {
                party.leaderID = newLeader
            }
            parties[partyID] = party
        } else {
            parties[partyID] = party
        }

        return true
    }

    /// Update member status (online/offline)
    public func updateMemberStatus(_ characterID: Character.ID, status: PartyMemberStatus) {
        guard let partyID = party(for: characterID)?.id else { return }
        guard var party = parties[partyID],
              var member = party.members[characterID] else { return }

        member.status = status
        party.members[characterID] = member
        parties[partyID] = party
    }

    /// Update member location
    public func updateMemberLocation(_ characterID: Character.ID, channel: UInt8, map: Map.ID) {
        guard let partyID = party(for: characterID)?.id else { return }
        guard var party = parties[partyID],
              var member = party.members[characterID] else { return }

        member.channel = channel
        member.map = map
        party.members[characterID] = member
        parties[partyID] = party
    }

    /// Disband party
    public func disbandParty(_ partyID: PartyID) {
        parties.removeValue(forKey: partyID)
    }

    /// Transfer party leadership.
    @discardableResult
    public func transferLeadership(_ partyID: PartyID, to characterID: Character.ID) -> Bool {
        guard var party = parties[partyID] else { return false }
        guard party.members[characterID] != nil else { return false }
        party.leaderID = characterID
        parties[partyID] = party
        return true
    }

    /// Load parties from database
    public func loadParties(from database: some ModelStorage) async throws {
        // TODO: Implement database loading
    }

    /// Save parties to database
    public func saveParties(to database: some ModelStorage) async throws {
        // TODO: Implement database saving
    }
}
