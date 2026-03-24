//
//  MonsterCarnivalDiedNotification.swift
//
//

import Foundation

public struct MonsterCarnivalDiedNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .monsterCarnivalDied }

    public let team: UInt8
    public let name: String
    public let lostCP: UInt8

    public init(team: UInt8, name: String, lostCP: UInt8) {
        self.team = team
        self.name = name
        self.lostCP = lostCP
    }
}

extension MonsterCarnivalDiedNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(team)
        try container.encodeMapleAsciiString(name)
        try container.encode(lostCP)
    }
}

