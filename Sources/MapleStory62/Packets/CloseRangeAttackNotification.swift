//
//  CloseRangeAttackNotification.swift
//
//

import Foundation

public struct CloseRangeAttackNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .closeRangeAttack }

    public init() { }
}

