//
//  GuildMemberEntity.swift
//
//
//  Created by Alsey Coleman Miller on 3/25/26.
//

import Foundation
import CoreModel
import MapleStory

/// Guild member entity (persisted in database)
public struct GuildMemberEntity: Codable, Equatable, Hashable, Identifiable, Sendable {
    
    public let id: UUID
    
    /// The guild this member belongs to
    public let guild: GuildEntity.ID
    
    /// The character ID
    public let characterID: Character.ID
    
    /// Character's name (for quick lookup)
    public let characterName: CharacterName
    
    /// Member's rank
    public var rank: GuildRank
    
    /// Member's online status
    public var online: Bool
    
    /// When the member joined the guild
    public var joinedAt: Date?
    
    public init(
        id: UUID = UUID(),
        guild: GuildEntity.ID,
        characterID: Character.ID,
        characterName: CharacterName,
        rank: GuildRank = .member,
        online: Bool = false,
        joinedAt: Date? = nil
    ) {
        self.id = id
        self.guild = guild
        self.characterID = characterID
        self.characterName = characterName
        self.rank = rank
        self.online = online
        self.joinedAt = joinedAt
    }

    // MARK: - Codable

    public enum CodingKeys: String, CodingKey, CaseIterable, Sendable {
        case id
        case guild
        case characterID
        case characterName
        case rank
        case online
        case joinedAt
    }
}

// MARK: - Entity

extension GuildMemberEntity: Entity {

    public static var entityName: EntityName { "GuildMember" }

    public static var attributes: [CodingKeys: AttributeType] {
        [
            .characterName: .string,
            .rank: .int16,
            .online: .bool,
            .joinedAt: .date
        ]
    }

    public static var relationships: [CodingKeys: Relationship] {
        [
            .guild: Relationship(
                id: .guild,
                entity: GuildMemberEntity.self,
                destination: GuildEntity.self,
                type: .toOne,
                inverseRelationship: .id
            ),
            .characterID: Relationship(
                id: .characterID,
                entity: GuildMemberEntity.self,
                destination: Character.self,
                type: .toOne,
                inverseRelationship: .id
            )
        ]
    }
}
