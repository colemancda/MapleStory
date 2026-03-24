//
//  WhisperNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Whisper message notification
public struct WhisperNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .whisper }

    public let sender: String

    public let message: String

    public init(sender: String, message: String) {
        self.sender = sender
        self.message = message
    }
}
