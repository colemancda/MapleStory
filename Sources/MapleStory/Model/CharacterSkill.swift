//
//  CharacterSkill.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel

/// Character's skill level and mastery level
public struct CharacterSkill: Codable, Equatable, Hashable, Identifiable, Sendable {

    public let id: UUID

    public let characterID: Character.ID

    public let skillID: UInt32

    /// Current skill level (0-maxLevel)
    public var level: UInt8

    /// Maximum attainable level for this skill (from skill books)
    public var masteryLevel: UInt8

    public init(
        id: UUID = UUID(),
        characterID: Character.ID,
        skillID: UInt32,
        level: UInt8 = 0,
        masteryLevel: UInt8 = 0
    ) {
        self.id = id
        self.characterID = characterID
        self.skillID = skillID
        self.level = level
        self.masteryLevel = masteryLevel
    }
}

// MARK: - Entity

extension CharacterSkill: Entity {

    public enum CodingKeys: String, CodingKey, CaseIterable, Sendable {
        case id
        case characterID
        case skillID
        case level
        case masteryLevel
    }

    public static var attributes: [CodingKeys: AttributeType] {
        [
            .id: .string,
            .characterID: .string,
            .skillID: .int64,
            .level: .int32,
            .masteryLevel: .int32
        ]
    }

    public static var relationships: [CodingKeys: Relationship] {
        [:]
    }
}
