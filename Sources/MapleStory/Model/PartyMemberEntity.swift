//
//  PartyMemberEntity.swift
//
//
//  Created by Alsey Coleman Miller on 3/25/26.
//

import Foundation
import CoreModel
import MapleStory

/// Party member entity (persisted in database)
public struct PartyMemberEntity: Codable, Equatable, Hashable, Identifiable, Sendable {
    
    public let id: UUID
    
    /// The party this member belongs to
    public let party: PartyEntity.ID
    
    /// The character ID
    public let characterID: Character.ID
    
    /// Character's name (for quick lookup)
    public let characterName: CharacterName
    
    /// Member's job
    public var job: Job
    
    /// Member's level
    public var level: UInt16
    
    /// Channel the member is on
    public var channel: UInt8
    
    /// Map the member is in
    public var map: Map.ID
    
    /// Member's online status
    public var status: PartyMemberStatus
    
    public init(
        id: UUID = UUID(),
        party: PartyEntity.ID,
        characterID: Character.ID,
        characterName: CharacterName,
        job: Job,
        level: UInt16,
        channel: UInt8,
        map: Map.ID,
        status: PartyMemberStatus = .online
    ) {
        self.id = id
        self.party = party
        self.characterID = characterID
        self.characterName = characterName
        self.job = job
        self.level = level
        self.channel = channel
        self.map = map
        self.status = status
    }
    
    // MARK: - Codable
    
    public enum CodingKeys: String, CodingKey, CaseIterable, Sendable {
        case id
        case party
        case characterID
        case characterName
        case job
        case level
        case channel
        case map
        case status
    }
}

// MARK: - Entity

extension PartyMemberEntity: Entity {
    
    public static var entityName: EntityName { "PartyMember" }
    
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .characterName: .string,
            .job: .int32,
            .level: .int32,
            .channel: .int16,
            .map: .int64,
            .status: .int16
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .party: Relationship(
                id: .party,
                entity: PartyMemberEntity.self,
                destination: PartyEntity.self,
                type: .toOne,
                inverseRelationship: .leaderID
            ),
            .characterID: Relationship(
                id: .characterID,
                entity: PartyMemberEntity.self,
                destination: Character.self,
                type: .toOne,
                inverseRelationship: .id
            )
        ]
    }
}

// MARK: - Conversion

extension PartyMemberEntity {
    
    /// Convert to PartyMember for protocol communication
    public func toPartyMember() -> PartyMember {
        PartyMember(
            characterID: characterID,
            characterName: characterName,
            job: job,
            level: level,
            channel: channel,
            map: map,
            status: status
        )
    }
}

