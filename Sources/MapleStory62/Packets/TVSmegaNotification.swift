//
//  TVSmegaNotification.swift
//
//

import Foundation

public struct TVSmegaNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .tvSmega }

    public init() { }
}

