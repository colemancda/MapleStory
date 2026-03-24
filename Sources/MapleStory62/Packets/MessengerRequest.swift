//
//  MessengerRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct MessengerRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .messenger }

    public let mode: UInt8
}

extension MessengerRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.mode = try container.decode(UInt8.self)
        // remaining bytes vary by mode — not parsed
    }
}
