//
//  SpecialMoveRequest.swift
//

import Foundation

/// Skill cast (special move) request.
public struct SpecialMoveRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .specialMove }

    /// Character position before cast
    public let oldX: Int16
    public let oldY: Int16

    /// Skill being cast
    public let skillID: UInt32

    /// Skill level used
    public let skillLevel: UInt8
}

extension SpecialMoveRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.oldX = try container.decode(Int16.self)
        self.oldY = try container.decode(Int16.self)
        self.skillID = try container.decode(UInt32.self)
        self.skillLevel = try container.decode(UInt8.self)
        // remaining bytes (target position, monster magnet data) are intentionally ignored
    }
}
