//
//  GuildOperationNotification.swift
//

import Foundation
import MapleStory

/// Response to guild operations.
public struct GuildOperationNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .guildOperation }

    public let operation: GuildOperation
    public let guildID: GuildID?

    public init(operation: GuildOperation, guildID: GuildID? = nil) {
        self.operation = operation
        self.guildID = guildID
    }

    public enum GuildOperation: UInt8, Codable, Equatable, Hashable, Sendable {
        case create  = 0x02
        case leave   = 0x05
        case expel   = 0x0C
        case rank    = 0x0E
        case disband = 0x10
    }
}

extension GuildOperationNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(operation.rawValue)
        if let guildID {
            try container.encode(guildID, isLittleEndian: true)
        }
    }
}
