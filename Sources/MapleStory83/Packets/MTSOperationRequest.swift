//
//  MTSOperationRequest.swift
//

import Foundation

public struct MTSOperationRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .mtsOperation }

    public let mode: UInt8
}

extension MTSOperationRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.mode = try container.decode(UInt8.self)
        // remaining bytes vary by mode — not parsed
    }
}
