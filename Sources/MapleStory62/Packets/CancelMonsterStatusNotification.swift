//
//  CancelMonsterStatusNotification.swift
//
//

import Foundation

public struct CancelMonsterStatusNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .cancelMonsterStatus }

    public init() { }
}

