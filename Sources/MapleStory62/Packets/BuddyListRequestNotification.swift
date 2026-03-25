//
//  BuddyListRequestNotification.swift
//  MapleStory62
//
//  Created by Coleman on 3/24/26.
//

import Foundation

/// Notification sent when someone requests to add you to their buddy list.
public struct BuddyListRequestNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .buddylist }

    /// Character ID of the person requesting to add you
    public let characterID: UInt32

    /// Name of the character requesting to add you
    public let characterName: CharacterName

    /// Notification type (1 for buddy request)
    public let notificationType: UInt8

    public init(characterID: UInt32, characterName: CharacterName) {
        self.characterID = characterID
        self.characterName = characterName
        self.notificationType = 1
    }
}

extension BuddyListRequestNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(notificationType)
        try container.encode(characterID)
        try container.encode(characterName)
    }
}
