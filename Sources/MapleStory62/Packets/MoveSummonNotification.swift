//
//  MoveSummonNotification.swift
//
//

import Foundation

public struct MoveSummonNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .moveSummon }

    public init() { }
}

