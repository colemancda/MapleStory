//
//  CancelBuffNotification.swift
//

import Foundation

/// Notifies a client that a buff has been cancelled.
public struct CancelBuffNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .cancelBuff }

    public let skillID: UInt32

    public init(skillID: UInt32) {
        self.skillID = skillID
    }
}

extension CancelBuffNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(skillID, isLittleEndian: true)
    }
}
