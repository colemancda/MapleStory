//
//  MultiChatNotification.swift
//

import Foundation

/// Multi-chat (buddy/party/guild) message notification.
///
/// mode: 0=buddy, 1=party, 2=guild, 3=alliance
public struct MultiChatNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .multichat }

    public let mode: UInt8

    public let name: String

    public let message: String
}
