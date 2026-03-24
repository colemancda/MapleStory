//
//  Party.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel

/// Party ID
public typealias PartyID = UInt32

/// Party member status
public enum PartyMemberStatus: UInt8, Codable, Equatable, Hashable, Sendable {
    case online = 0
    case offline = 1
}

/// Party member data
public struct PartyMember: Codable, Equatable, Hashable, Sendable {

    public let characterID: Character.ID

    public let characterName: CharacterName

    public let job: Job

    public let level: UInt16

    public let channel: UInt8

    public let map: Map.ID

    public var status: PartyMemberStatus

    public init(
        characterID: Character.ID,
        characterName: CharacterName,
        job: Job,
        level: UInt16,
        channel: UInt8,
        map: Map.ID,
        status: PartyMemberStatus = .online
    ) {
        self.characterID = characterID
        self.characterName = characterName
        self.job = job
        self.level = level
        self.channel = channel
        self.map = map
        self.status = status
    }
}

/// Party
public struct Party: Codable, Equatable, Hashable, Identifiable, Sendable {

    public let id: PartyID

    /// Party leader
    public var leaderID: Character.ID

    /// Party members
    public var members: [Character.ID: PartyMember]

    /// Current member count
    public var memberCount: Int {
        members.count
    }

    /// Check if party is full (max 6 members)
    public var isFull: Bool {
        members.count >= 6
    }

    public init(
        id: PartyID = PartyID(UInt32.random(in: 1000...999999)),
        leaderID: Character.ID,
        members: [Character.ID: PartyMember] = [:]
    ) {
        self.id = id
        self.leaderID = leaderID
        self.members = members
    }
}
