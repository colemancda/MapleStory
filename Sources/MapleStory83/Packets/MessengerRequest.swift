//
//  MessengerRequest.swift
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
