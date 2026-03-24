//
//  PlayerNPCNotification.swift
//
//

import Foundation

public struct PlayerNPCNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .playerNPC }

    public init() { }
}

