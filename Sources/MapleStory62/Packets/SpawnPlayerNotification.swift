//
//  SpawnPlayerNotification.swift
//
//

import Foundation

public struct SpawnPlayerNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnPlayer }

    public init() { }
}

