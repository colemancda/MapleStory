//
//  RemoveNPCNotification.swift
//

import Foundation

/// Remove NPC from the map.
public struct RemoveNPCNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .removeNPC }

    public let objectID: UInt32
}
