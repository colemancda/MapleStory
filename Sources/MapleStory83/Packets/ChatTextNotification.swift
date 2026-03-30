//
//  ChatTextNotification.swift
//

import Foundation

/// General chat text notification sent to nearby players.
///
public struct ChatTextNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .chattext }

    public let characterID: UInt32

    public let isGM: Bool

    public let message: String

    public let show: UInt8

    public init(characterID: UInt32, isGM: Bool, message: String, show: UInt8) {
        self.characterID = characterID
        self.isGM = isGM
        self.message = message
        self.show = show
    }
}
