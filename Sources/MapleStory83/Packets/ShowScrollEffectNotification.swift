//
//  ShowScrollEffectNotification.swift
//

import Foundation

/// Scroll effect result broadcast to nearby players.
///
public struct ShowScrollEffectNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showScrollEffect }

    public let characterID: UInt32

    public let success: Bool

    public let curse: Bool

    public let legendarySpirit: Bool

    public let whiteScroll: Bool
}
