//
//  RemoveSummonNotification.swift
//

import Foundation

/// Removes a summon (special map object) for nearby clients.
///
public struct RemoveSummonNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .removeSpecialMapobject }

    public let ownerCharacterID: UInt32

    public let summonObjectID: UInt32

    /// 4 = animated, 1 = instant.
    public let animationType: UInt8
}
