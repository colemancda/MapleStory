//
//  CSOpenNotification.swift
//
//

import Foundation

public struct CSOpenNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .csOpen }

    public init() { }
}

