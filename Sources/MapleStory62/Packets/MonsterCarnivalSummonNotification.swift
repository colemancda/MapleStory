//
//  MonsterCarnivalSummonNotification.swift
//
//

import Foundation

public struct MonsterCarnivalSummonNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .monsterCarnivalSummon }

    public let tab: UInt8
    public let number: UInt8
    public let name: String

    public init(tab: UInt8, number: UInt8, name: String) {
        self.tab = tab
        self.number = number
        self.name = name
    }
}

extension MonsterCarnivalSummonNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(tab)
        try container.encode(number)
        try container.encodeMapleAsciiString(name)
    }
}

