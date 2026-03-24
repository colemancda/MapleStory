//
//  ChatTextNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct ChatTextNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .chattext }

    /// Character integer ID (character.index).
    public let characterID: UInt32

    public let isAdmin: Bool

    public let message: String

    public let show: Bool

    public init(characterID: UInt32, isAdmin: Bool = false, message: String, show: Bool) {
        self.characterID = characterID
        self.isAdmin = isAdmin
        self.message = message
        self.show = show
    }
}
