//
//  GuildOperationRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct GuildOperationRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .guildOperation }

    public let type: UInt8
}

extension GuildOperationRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.type = try container.decode(UInt8.self)
        // remaining bytes vary by type — not parsed
    }
}
