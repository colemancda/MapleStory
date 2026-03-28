//
//  MovePetNotification.swift
//

import Foundation

/// Pet movement broadcast to nearby players.
///
public struct MovePetNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .movePet }

    public let characterID: UInt32

    public let petSlot: UInt8

    public let petUniqueID: UInt32

    public let movements: [Movement]
}
