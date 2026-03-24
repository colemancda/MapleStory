//
//  MonsterCarnivalPartyCpNotification.swift
//
//

import Foundation

public struct MonsterCarnivalPartyCpNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .monsterCarnivalPartyCP }

    public let team: UInt8
    public let currentCP: UInt16
    public let totalCP: UInt16

    public init(team: UInt8, currentCP: UInt16, totalCP: UInt16) {
        self.team = team
        self.currentCP = currentCP
        self.totalCP = totalCP
    }
}

extension MonsterCarnivalPartyCpNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(team)
        try container.encode(currentCP, isLittleEndian: true)
        try container.encode(totalCP, isLittleEndian: true)
    }
}

