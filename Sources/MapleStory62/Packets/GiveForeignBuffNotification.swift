//
//  GiveForeignBuffNotification.swift
//
//

import Foundation

public struct GiveForeignBuffNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .giveForeignBuff }

    public init() { }
}

