//
//  CSOperationNotification.swift
//
//

import Foundation

public struct CSOperationNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .csOperation }

    public init() { }
}

