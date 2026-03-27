//
//  Door.swift
//  MapleStoryServer62
//
//  Created by Coleman on 3/24/26.
//

import Foundation
import CoreModel
import MapleStory

/// Mystic Door object
///
/// Represents a teleportation door created by a Priest's Mystic Door skill.
/// Links a field map to a town portal, allowing party members to travel between them.
public struct Door: Codable, Equatable, Hashable, Sendable {

    /// ID of the character who created the door
    public let ownerID: Character.ID

    /// Town map ID where the door portal is located
    public let townMapID: Map.ID

    /// Portal ID in the town (type 6 - DOOR_PORTAL)
    public let townPortalID: UInt8

    /// Field map ID where the door was created
    public let fieldMapID: Map.ID

    /// Position in the field map where the door is located
    public let fieldPosition: Position

    /// Creation time for door expiration checking
    public let createdAt: Date

    /// Door skill duration in seconds (default: 5 minutes for level 1 Mystic Door)
    public let duration: TimeInterval

    public init(
        ownerID: Character.ID,
        townMapID: Map.ID,
        townPortalID: UInt8,
        fieldMapID: Map.ID,
        fieldPosition: Position,
        duration: TimeInterval = 300.0
    ) {
        self.ownerID = ownerID
        self.townMapID = townMapID
        self.townPortalID = townPortalID
        self.fieldMapID = fieldMapID
        self.fieldPosition = fieldPosition
        self.createdAt = Date()
        self.duration = duration
    }

    /// Check if the door has expired
    public var isExpired: Bool {
        Date().timeIntervalSince(createdAt) >= duration
    }

    /// Check if a character can use this door
    /// - Parameters:
    ///   - characterID: The character attempting to use the door
    ///   - partyMembers: The members of the character's party (if any)
    /// - Returns: True if the character is the owner or in the owner's party
    public func canBeUsed(by characterID: Character.ID, partyMembers: [PartyMemberEntity]) -> Bool {
        // Owner can always use their own door
        if characterID == ownerID {
            return true
        }

        // Party members can use the door if the owner is also in the party
        return partyMembers.contains { $0.characterID == ownerID }
    }
}

/// 2D Position
public struct Position: Codable, Equatable, Hashable, Sendable {
    public let x: Int16
    public let y: Int16

    public init(x: Int16, y: Int16) {
        self.x = x
        self.y = y
    }
}
