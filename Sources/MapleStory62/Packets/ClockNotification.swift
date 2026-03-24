//
//  ClockNotification.swift
//
//

import Foundation

public enum ClockNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .clock }

    /// Type 2: countdown clock in seconds.
    case countdown(seconds: UInt32)

    /// Type 1: absolute server time.
    case time(hour: UInt8, minute: UInt8, second: UInt8)
}

extension ClockNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case .countdown(let seconds):
            try container.encode(UInt8(2))
            try container.encode(seconds, isLittleEndian: true)
        case .time(let hour, let minute, let second):
            try container.encode(UInt8(1))
            try container.encode(hour)
            try container.encode(minute)
            try container.encode(second)
        }
    }
}

