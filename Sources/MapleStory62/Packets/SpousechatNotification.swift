//
//  SpousechatNotification.swift
//
//

import Foundation

public struct SpousechatNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spousechat }

    public init() { }
}

