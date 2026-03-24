//
//  GuildOperationNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Response to guild operations
public struct GuildOperationNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .guildOperation }

    /// Operation type
    public let operation: GuildOperation

    /// Guild ID (nil if disbanded/left)
    public let guildID: GuildID?

    public init(operation: GuildOperation, guildID: GuildID? = nil) {
        self.operation = operation
        self.guildID = guildID
    }

    /// Guild operation type
    public enum GuildOperation: UInt8, Codable, Equatable, Hashable, Sendable {
        case create = 0x02
        case leave = 0x05
        case expel = 0x0C
        case rank = 0x0E
        case disband = 0x10
    }
}
