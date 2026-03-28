//
//  SpouseChatRequest.swift
//

import Foundation

public struct SpouseChatRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .spouseChat }

    public let recipient: String

    public let message: String
}
