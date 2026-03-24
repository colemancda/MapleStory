//
//  RangedAttackNotification.swift
//
//

import Foundation

public struct RangedAttackNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .rangedAttack }

    public init() { }
}

