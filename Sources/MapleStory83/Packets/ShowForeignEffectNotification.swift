//
//  ShowForeignEffectNotification.swift
//

import Foundation

/// Shows a skill/item effect on another player.
///
public struct ShowForeignEffectNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showForeignEffect }

    public let characterID: UInt32

    public let effect: UInt8
}
