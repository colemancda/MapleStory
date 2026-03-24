//
//  CharacterSkill.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel

/// Character's skill level and mastery level
public struct CharacterSkill: Codable, Equatable, Hashable, Sendable {

    public let characterID: Character.ID

    public let skillID: UInt32

    /// Current skill level (0-maxLevel)
    public var level: UInt8

    /// Maximum attainable level for this skill (from skill books)
    public var masteryLevel: UInt8

    public init(
        characterID: Character.ID,
        skillID: UInt32,
        level: UInt8 = 0,
        masteryLevel: UInt8 = 0
    ) {
        self.characterID = characterID
        self.skillID = skillID
        self.level = level
        self.masteryLevel = masteryLevel
    }
}

// MARK: - Entity

extension CharacterSkill: Entity {

    public static var attributes: [String: AttributeType] {
        [
            "characterID": .string,
            "skillID": .int64,
            "level": .int32,
            "masteryLevel": .int32
        ]
    }

    public static var relationships: [String: Relationship] {
        [
            "characterID": Relationship(
                id: "characterID",
                entity: CharacterSkill.self,
                destination: Character.self,
                type: .toOne,
                inverseRelationship: nil
            )
        ]
    }
}
