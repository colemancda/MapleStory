//
//  RemoveDoorNotification.swift
//

import Foundation

/// Removes a mystic door from the map.
///
public struct RemoveDoorNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .removeDoor }

    public let unknown: UInt8

    public let ownerID: UInt32
}
