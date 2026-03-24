//
//  BuffState.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// Tracks an active buff on a character.
public struct BuffState: Codable, Equatable, Hashable, Sendable {

    /// Skill ID that applied this buff
    public let skillID: UInt32

    /// Skill level used
    public let level: Int

    /// When this buff expires
    public let expiry: Date

    /// When this buff was applied
    public let startTime: Date

    /// Create a new buff state
    public init(skillID: UInt32, level: Int, duration: TimeInterval, startTime: Date = Date()) {
        self.skillID = skillID
        self.level = level
        self.expiry = startTime.addingTimeInterval(duration)
        self.startTime = startTime
    }

    /// Check if this buff has expired
    public var isExpired: Bool {
        return Date() > expiry
    }

    /// Remaining duration in seconds
    public var remainingTime: TimeInterval {
        return max(0, expiry.timeIntervalSinceNow)
    }
}

/// Registry tracking active buffs on characters.
public actor CharacterBuffRegistry {

    public static let shared = CharacterBuffRegistry()

    /// Character ID -> Active buffs
    private var buffs: [Character.ID: [BuffState]] = [:]

    private init() {}

    // MARK: - Buff Management

    /// Apply a buff to a character.
    public func applyBuff(
        _ buff: BuffState,
        to characterID: Character.ID
    ) {
        if buffs[characterID] == nil {
            buffs[characterID] = []
        }
        buffs[characterID]?.append(buff)
    }

    /// Remove all buffs with a specific skill ID from a character.
    @discardableResult
    public func removeBuff(
        skillID: UInt32,
        from characterID: Character.ID
    ) -> Bool {
        guard var characterBuffs = buffs[characterID] else {
            return false
        }
        let originalCount = characterBuffs.count
        characterBuffs.removeAll { $0.skillID == skillID }
        buffs[characterID] = characterBuffs.isEmpty ? nil : characterBuffs
        return characterBuffs.count < originalCount
    }

    /// Remove a specific buff (by skill ID and level).
    @discardableResult
    public func removeBuff(
        skillID: UInt32,
        level: Int,
        from characterID: Character.ID
    ) -> Bool {
        guard var characterBuffs = buffs[characterID] else {
            return false
        }
        let originalCount = characterBuffs.count
        characterBuffs.removeAll { $0.skillID == skillID && $0.level == level }
        buffs[characterID] = characterBuffs.isEmpty ? nil : characterBuffs
        return characterBuffs.count < originalCount
    }

    /// Get all active buffs for a character.
    public func buffs(for characterID: Character.ID) -> [BuffState] {
        guard let characterBuffs = buffs[characterID] else {
            return []
        }
        return characterBuffs.filter { !$0.isExpired }
    }

    /// Remove expired buffs for a character.
    public func cleanupExpired(for characterID: Character.ID) {
        guard var characterBuffs = buffs[characterID] else {
            return
        }
        characterBuffs = characterBuffs.filter { !$0.isExpired }
        buffs[characterID] = characterBuffs.isEmpty ? nil : characterBuffs
    }

    /// Clear all buffs for a character (e.g., on death or logout).
    public func clearAll(for characterID: Character.ID) {
        buffs[characterID] = nil
    }

    /// Check if a character has an active buff from a specific skill.
    public func hasBuff(
        skillID: UInt32,
        for characterID: Character.ID
    ) -> Bool {
        guard let characterBuffs = buffs[characterID] else {
            return false
        }
        return characterBuffs.contains { $0.skillID == skillID && !$0.isExpired }
    }
}
