//
//  MonsterCarnivalStartNotification.swift
//
//

import Foundation

public struct MonsterCarnivalStartNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .monsterCarnivalStart }

    public let team: UInt8

    public init(team: UInt8) {
        self.team = team
    }
}

extension MonsterCarnivalStartNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(team)
        try container.encode([UInt8](repeating: 0, count: 22))
    }
}

