//
//  ShowMonsterHPNotification.swift
//
//

import Foundation

public struct ShowMonsterHPNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showMonsterHP }

    public let objectID: UInt32
    public let remainingHPPercent: UInt8

    public init(objectID: UInt32, remainingHPPercent: UInt8) {
        self.objectID = objectID
        self.remainingHPPercent = remainingHPPercent
    }
}

extension ShowMonsterHPNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(objectID, isLittleEndian: true)
        try container.encode(remainingHPPercent)
    }
}

