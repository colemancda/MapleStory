//
//  RemoveDragonNotification.swift
//

import Foundation

/// Removes the Evan dragon (Mir) for nearby clients.
///
public struct RemoveDragonNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .removeDragon }

    public let ownerCharacterID: UInt32
}
