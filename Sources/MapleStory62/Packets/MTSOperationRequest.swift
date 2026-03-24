//
//  MTSOperationRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct MTSOperationRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .mtsTab }

    public let operation: UInt8
}

extension MTSOperationRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.operation = try container.decode(UInt8.self)
        // remaining bytes vary by operation — not parsed
    }
}
