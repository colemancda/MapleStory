//
//  UseInnerPortalRequest.swift
//

import Foundation

/// Inner portal usage request packet.
///
/// **Note**: This packet is intentionally ignored by the server (no-op handler).
/// It was designed for anti-cheat detection but was never fully implemented.
public struct UseInnerPortalRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .useInnerPortal }

    public let flag: UInt8

    public let portalName: String

    public let targetX: Int16

    public let targetY: Int16

    public let currentX: Int16

    public let currentY: Int16
}

extension UseInnerPortalRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.flag = try container.decode(UInt8.self)
        self.portalName = try container.decode(String.self)
        self.targetX = try container.decode(Int16.self)
        self.targetY = try container.decode(Int16.self)
        self.currentX = try container.decode(Int16.self)
        self.currentY = try container.decode(Int16.self)
    }
}
