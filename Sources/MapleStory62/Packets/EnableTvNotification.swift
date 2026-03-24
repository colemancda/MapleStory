//
//  EnableTvNotification.swift
//
//

import Foundation

public struct EnableTvNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .enableTV }

    public let value0: UInt32
    public let value1: UInt8

    public init(value0: UInt32 = 0, value1: UInt8 = 0) {
        self.value0 = value0
        self.value1 = value1
    }
}

extension EnableTvNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(value0, isLittleEndian: true)
        try container.encode(value1)
    }
}

