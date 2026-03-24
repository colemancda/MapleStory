//
//  ZakumShrineNotification.swift
//
//

import Foundation

public struct ZakumShrineNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .zakumShrine }

    public let mode: UInt8
    public let timeLeft: UInt32

    public init(mode: UInt8 = 0, timeLeft: UInt32) {
        self.mode = mode
        self.timeLeft = timeLeft
    }
}

extension ZakumShrineNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(mode)
        try container.encode(timeLeft, isLittleEndian: true)
    }
}

