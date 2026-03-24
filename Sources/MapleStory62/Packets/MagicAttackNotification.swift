//
//  MagicAttackNotification.swift
//
//

import Foundation

public struct MagicAttackNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .magicAttack }

    public init() { }
}

