//
//  WhisperNotification.swift
//

import Foundation

/// Whisper send result or incoming whisper message.
///
public struct WhisperNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .whisper }

    public let flag: UInt8

    public let characterName: String

    /// For RECEIVE: channel number. For RESULT: success bool as UInt8.
    public let channelOrSuccess: UInt8?

    public let fromAdmin: Bool?

    public let message: String?
}
