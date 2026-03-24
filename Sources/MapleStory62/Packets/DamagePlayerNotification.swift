//
//  DamagePlayerNotification.swift
//
//

import Foundation

public struct DamagePlayerNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .damagePlayer }

    public init() { }
}

