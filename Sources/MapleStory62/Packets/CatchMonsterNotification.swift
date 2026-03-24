//
//  CatchMonsterNotification.swift
//
//

import Foundation

public struct CatchMonsterNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .catchMonster }

    public let mobID: UInt32
    public let itemID: UInt32
    public let success: UInt8

    public init(mobID: UInt32, itemID: UInt32, success: UInt8) {
        self.mobID = mobID
        self.itemID = itemID
        self.success = success
    }
}

extension CatchMonsterNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(mobID, isLittleEndian: true)
        try container.encode(itemID, isLittleEndian: true)
        try container.encode(success)
    }
}

