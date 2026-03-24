//
//  ApplyMonsterStatusNotification.swift
//
//

import Foundation

public struct ApplyMonsterStatusNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .applyMonsterStatus }

    public init() { }
}

