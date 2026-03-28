//
//  ChangeChannelRequest.swift
//

import Foundation

public struct ChangeChannelRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .changeChannel }

    /// Channel number (0-indexed)
    public let channel: UInt8
}
