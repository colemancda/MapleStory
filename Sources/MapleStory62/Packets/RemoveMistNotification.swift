//
//  RemoveMistNotification.swift
//
//

import Foundation

public struct RemoveMistNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .removeMist }

    public let objectID: UInt32

    public init(objectID: UInt32) {
        self.objectID = objectID
    }
}

extension RemoveMistNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(objectID, isLittleEndian: true)
    }
}

