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

    public init(from container: ModelData) throws {
        guard container.entity.rawValue == Self.entityName.rawValue else {
            throw CoreModel.CoreModelError.invalidEntity(container.entity)
        }
        guard let id = Self.ID(objectID: container.id) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Cannot decode identifier from \(container.id)"))
        }
        self.id = id
        self.characterID = try container.decode(Character.ID.self, forKey: CharacterSkill.CodingKeys.characterID)
        self.skillID = try container.decode(UInt32.self, forKey: CharacterSkill.CodingKeys.skillID)
        self.level = try container.decode(UInt8.self, forKey: CharacterSkill.CodingKeys.level)
        self.masteryLevel = try container.decode(UInt8.self, forKey: CharacterSkill.CodingKeys.masteryLevel)
    }

    public func encode() -> ModelData {
        var container = ModelData(
            entity: Self.entityName,
            id: ObjectID(self.id)
        )
        container.encode(self.characterID, forKey: CharacterSkill.CodingKeys.characterID)
        container.encode(self.skillID, forKey: CharacterSkill.CodingKeys.skillID)
        container.encode(self.level, forKey: CharacterSkill.CodingKeys.level)
        container.encode(self.masteryLevel, forKey: CharacterSkill.CodingKeys.masteryLevel)
        return container
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
