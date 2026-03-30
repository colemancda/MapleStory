//
//  PetChatNotification.swift
//

import Foundation

/// Pet speech bubble broadcast to nearby players.
///
public struct PetChatNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .petChat }

    public let characterID: UInt32

    public let petSlot: UInt8

    public let unknown: UInt8

    public let action: UInt8

    public let text: String

    public let unknown2: UInt8

    public init(characterID: UInt32, slot: UInt8, unknown: UInt8, text: String) {
        self.characterID = characterID
        self.petSlot = slot
        self.unknown = unknown
        self.action = 0
        self.text = text
        self.unknown2 = 0
    }
}
