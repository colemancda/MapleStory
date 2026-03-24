//
//  CSUpdateNotification.swift
//
//

import Foundation

public struct CSUpdateNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .csUpdate }

    public init() { }
}

