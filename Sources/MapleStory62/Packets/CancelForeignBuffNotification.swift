//
//  CancelForeignBuffNotification.swift
//
//

import Foundation

public struct CancelForeignBuffNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .cancelForeignBuff }

    public init() { }
}

