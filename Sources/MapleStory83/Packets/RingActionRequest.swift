//
//  RingActionRequest.swift
//

import Foundation

public struct RingActionRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .ringAction }

    public let mode: UInt8
}

extension RingActionRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.mode = try container.decode(UInt8.self)
        // remaining bytes vary by mode — not parsed
    }
}
