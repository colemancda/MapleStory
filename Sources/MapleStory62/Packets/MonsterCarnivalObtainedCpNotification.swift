//
//  MonsterCarnivalObtainedCpNotification.swift
//
//

import Foundation

public struct MonsterCarnivalObtainedCpNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .monsterCarnivalObtainedCP }

    public let currentCP: UInt16
    public let totalCP: UInt16

    public init(currentCP: UInt16, totalCP: UInt16) {
        self.currentCP = currentCP
        self.totalCP = totalCP
    }
}

extension MonsterCarnivalObtainedCpNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(currentCP, isLittleEndian: true)
        try container.encode(totalCP, isLittleEndian: true)
    }
}

