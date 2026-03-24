//
//  ShowMagnetNotification.swift
//
//

import Foundation

public struct ShowMagnetNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showMagnet }

    public let mobID: UInt32
    public let success: UInt8

    public init(mobID: UInt32, success: UInt8) {
        self.mobID = mobID
        self.success = success
    }
}

extension ShowMagnetNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(mobID, isLittleEndian: true)
        try container.encode(success)
    }
}

