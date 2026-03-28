//
//  RemovePlayerFromMapNotification.swift
//

import Foundation

/// Removes a player from the map for all nearby clients.
///
public struct RemovePlayerFromMapNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .removePlayerFromMap }

    public let characterID: UInt32
}
