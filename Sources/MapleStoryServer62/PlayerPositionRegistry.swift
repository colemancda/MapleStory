//
//  PlayerPositionRegistry.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// Player position on a map
public struct PlayerPosition: Codable, Equatable, Hashable, Sendable {

    /// X coordinate
    public let x: Int16

    /// Y coordinate
    public let y: Int16

    /// Stance (0 = standing, 1 = walking, 2 = sitting, etc.)
    public let stance: UInt8

    /// Create position
    public init(x: Int16, y: Int16, stance: UInt8 = 0) {
        self.x = x
        self.y = y
        self.stance = stance
    }

    /// Calculate distance to another position
    func distance(to other: PlayerPosition) -> Int16 {
        let dx = Int32(x) - Int32(other.x)
        let dy = Int32(y) - Int32(other.y)
        return Int16(sqrt(Double(dx * dx + dy * dy)))
    }
}

/// Registry tracking player positions on all maps
public actor PlayerPositionRegistry {

    public static let shared = PlayerPositionRegistry()

    /// Character ID -> Position
    private var positions: [Character.ID: PlayerPosition] = [:]

    private init() {}

    // MARK: - Position Management

    /// Update player position
    public func updatePosition(_ position: PlayerPosition, for characterID: Character.ID) {
        positions[characterID] = position
    }

    /// Get player position
    public func position(for characterID: Character.ID) -> PlayerPosition? {
        positions[characterID]
    }

    /// Remove player position (on logout/map change)
    public func removePosition(for characterID: Character.ID) {
        positions[characterID] = nil
    }

    /// Check if player is within range of a position
    public func isInRange(
        characterID: Character.ID,
        position: PlayerPosition,
        range: Int16
    ) -> Bool {
        guard let playerPos = positions[characterID] else {
            return false
        }
        return playerPos.distance(to: position) <= range
    }
}
