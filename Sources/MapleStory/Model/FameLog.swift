//
//  FameLog.swift
//
//
//  Created by Alsey Coleman Miller on 3/25/26.
//

import Foundation
import CoreModel

/// Records when a character gave fame to another character.
/// Used to enforce the once-per-day and once-per-month-per-target fame rules.
public struct FameLog: Codable, Equatable, Hashable, Identifiable, Sendable {

    public let id: UUID

    /// The character who gave fame
    public let characterID: Character.ID

    /// The character who received fame
    public let characterIDTo: Character.ID

    /// When the fame was given
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        characterID: Character.ID,
        characterIDTo: Character.ID,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.characterID = characterID
        self.characterIDTo = characterIDTo
        self.timestamp = timestamp
    }

    public enum CodingKeys: String, CodingKey, CaseIterable, Sendable {
        case id
        case characterID
        case characterIDTo
        case timestamp
    }
}

// MARK: - Entity

extension FameLog: Entity {

    public static var attributes: [CodingKeys: AttributeType] {
        [
            .characterID: .string,
            .characterIDTo: .string,
            .timestamp: .date
        ]
    }

    public static var relationships: [CodingKeys: Relationship] {
        [:]
    }
}
