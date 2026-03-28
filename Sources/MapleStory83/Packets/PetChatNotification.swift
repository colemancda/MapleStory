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
}
