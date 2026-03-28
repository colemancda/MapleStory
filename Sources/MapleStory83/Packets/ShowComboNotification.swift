//
//  ShowComboNotification.swift
//

import Foundation

/// Shows the Energy Charge / Combo counter to the player.
///
public struct ShowComboNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showCombo }

    public let count: UInt32
}
