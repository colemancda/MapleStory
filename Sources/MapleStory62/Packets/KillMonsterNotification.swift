//
//  KillMonsterNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Broadcast to all clients on a map when a monster dies.
/// Opcode: `killMonster` (0xB0)
public struct KillMonsterNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .killMonster }

    /// Monster map object ID.
    public let objectID: UInt32

    /// Whether to show a death animation (1) or remove instantly (0).
    public let animation: UInt8

    public init(objectID: UInt32, animation: UInt8 = 1) {
        self.objectID = objectID
        self.animation = animation
    }
}

extension KillMonsterNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(objectID)
        try container.encode(animation)
    }
}
