//
//  RemoveMistNotification.swift
//

import Foundation

/// Remove a mist object from the map.
///
public struct RemoveMistNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .removeMist }

    public let objectID: UInt32
}
