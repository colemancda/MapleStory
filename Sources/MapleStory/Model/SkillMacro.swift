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
