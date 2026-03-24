//
//  BossEnvNotification.swift
//
//

import Foundation

public struct BossEnvNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .bossEnv }

    public init() { }
}

