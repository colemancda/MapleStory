//
//  SpawnSpecialMapobjectNotification.swift
//
//

import Foundation

public struct SpawnSpecialMapobjectNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnSpecialMapobject }

    public init() { }
}

