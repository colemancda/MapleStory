//
//  SkillMacro.swift
//
//  Created by Alsey Coleman Miller
//

import Foundation
import CoreModel

/// Skill Macro Configuration
///
/// Represents a player's skill macro configuration. Players can create
/// macros that bind multiple skills to a single key, creating custom
/// skill combos.
public struct SkillMacro: Codable, Equatable, Hashable, Identifiable, Sendable {

    // MARK: - Properties

    public let id: UUID

    public let character: Character.ID

    /// Macro slot (0-9)
    public let slot: UInt8

    /// Custom name for the macro
    public let name: String

    /// Whether to shout the macro name when used
    public let shout: UInt8

    /// First skill in the macro chain
    public let skill1: UInt32

    /// Second skill in the macro chain
    public let skill2: UInt32

    /// Third skill in the macro chain
    public let skill3: UInt32

    // MARK: - Initialization

    public init(
        id: UUID = UUID(),
        character: Character.ID,
        slot: UInt8,
        name: String,
        shout: UInt8 = 0,
        skill1: UInt32 = 0,
        skill2: UInt32 = 0,
        skill3: UInt32 = 0
    ) {
        self.id = id
        self.character = character
        self.slot = slot
        self.name = name
        self.shout = shout
        self.skill1 = skill1
        self.skill2 = skill2
        self.skill3 = skill3
    }

    // MARK: - Codable

    public enum CodingKeys: String, CodingKey, CaseIterable, Sendable {
        case id
        case character
        case slot
        case name
        case shout
        case skill1
        case skill2
        case skill3
    }
}

// MARK: - Entity

extension SkillMacro: Entity {

    public init(from container: ModelData) throws {
        guard container.entity.rawValue == Self.entityName.rawValue else {
            throw CoreModel.CoreModelError.invalidEntity(container.entity)
        }
        guard let id = Self.ID(objectID: container.id) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Cannot decode identifier from \(container.id)"))
        }
        self.id = id
        self.slot = try container.decode(UInt8.self, forKey: SkillMacro.CodingKeys.slot)
        self.name = try container.decode(String.self, forKey: SkillMacro.CodingKeys.name)
        self.shout = try container.decode(UInt8.self, forKey: SkillMacro.CodingKeys.shout)
        self.skill1 = try container.decode(UInt32.self, forKey: SkillMacro.CodingKeys.skill1)
        self.skill2 = try container.decode(UInt32.self, forKey: SkillMacro.CodingKeys.skill2)
        self.skill3 = try container.decode(UInt32.self, forKey: SkillMacro.CodingKeys.skill3)
        self.character = try container.decodeRelationship(Character.ID.self, forKey: SkillMacro.CodingKeys.character)
    }

    public func encode() -> ModelData {
        var container = ModelData(
            entity: Self.entityName,
            id: ObjectID(self.id)
        )
        container.encode(self.slot, forKey: SkillMacro.CodingKeys.slot)
        container.encode(self.name, forKey: SkillMacro.CodingKeys.name)
        container.encode(self.shout, forKey: SkillMacro.CodingKeys.shout)
        container.encode(self.skill1, forKey: SkillMacro.CodingKeys.skill1)
        container.encode(self.skill2, forKey: SkillMacro.CodingKeys.skill2)
        container.encode(self.skill3, forKey: SkillMacro.CodingKeys.skill3)
        container.encodeRelationship(self.character, forKey: SkillMacro.CodingKeys.character)
        return container
    }

    public static var attributes: [CodingKeys: AttributeType] {
        [
            .slot: .int32,
            .name: .string,
            .shout: .int32,
            .skill1: .int64,
            .skill2: .int64,
            .skill3: .int64
        ]
    }

    public static var relationships: [CodingKeys: Relationship] {
        [
            .character: Relationship(
                id: .character,
                entity: SkillMacro.self,
                destination: Character.self,
                type: .toOne,
                inverseRelationship: .skillMacros
            )
        ]
    }
}

// MARK: - Supporting Types

public extension SkillMacro {

    /// Create skill macro from components
    init(
        character: Character.ID,
        slot: UInt8,
        name: String,
        shout: UInt8,
        skill1: UInt32,
        skill2: UInt32,
        skill3: UInt32
    ) {
        self.id = UUID()
        self.character = character
        self.slot = slot
        self.name = name
        self.shout = shout
        self.skill1 = skill1
        self.skill2 = skill2
        self.skill3 = skill3
    }
}
