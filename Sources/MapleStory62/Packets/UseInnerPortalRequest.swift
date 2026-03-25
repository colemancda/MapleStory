//
//  UseInnerPortalRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Inner portal usage request packet.
///
/// **Note**: This packet is intentionally ignored by the server (no-op handler).
/// It was designed for anti-cheat detection but was never fully implemented.
/// The server currently does not validate inner portal usage.
public struct UseInnerPortalRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .useInnerPortal }

    /// Unknown flag byte
    public let flag: UInt8

    /// Name of the portal being used
    public let portalName: String

    /// Target X position (where player wants to teleport)
    public let targetX: Int16

    /// Target Y position (where player wants to teleport)
    public let targetY: Int16

    /// Current X position (where player is currently)
    public let currentX: Int16

    /// Current Y position (where player is currently)
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
