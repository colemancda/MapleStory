//
//  RemovePlayerFromMapNotification.swift
//
//

import Foundation

public struct RemovePlayerFromMapNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .removePlayerFromMap }

    public init() { }
}

