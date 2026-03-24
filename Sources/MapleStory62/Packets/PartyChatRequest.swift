//
//  PartyChatRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct PartyChatRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .partyChat }

    public let type: UInt8

    public let recipients: [UInt32]

    public let message: String
}

extension PartyChatRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.type = try container.decode(UInt8.self)
        let count = try container.decode(UInt8.self)
        self.recipients = try (0 ..< count).map { _ in try container.decode(UInt32.self) }
        self.message = try container.decode(String.self)
    }
}
