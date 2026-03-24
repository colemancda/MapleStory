//
//  CooldownNotification.swift
//
//

import Foundation

public struct CooldownNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .cooldown }

    public let skillID: UInt32
    public let duration: UInt16

    public init(skillID: UInt32, duration: UInt16) {
        self.skillID = skillID
        self.duration = duration
    }
}

extension CooldownNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(skillID, isLittleEndian: true)
        try container.encode(duration, isLittleEndian: true)
    }
}

