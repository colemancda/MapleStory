//
//  PartyOperationRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct PartyOperationRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .partyOperation }

    public let operation: UInt8
}

extension PartyOperationRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.operation = try container.decode(UInt8.self)
        // remaining bytes vary by operation — not parsed
    }
}
