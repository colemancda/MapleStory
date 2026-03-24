//
//  RemoveDoorNotification.swift
//
//

import Foundation

public struct RemoveDoorNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .removeDoor }

    public let inTown: Bool
    public let objectID: UInt32

    public init(inTown: Bool = false, objectID: UInt32) {
        self.inTown = inTown
        self.objectID = objectID
    }
}

extension RemoveDoorNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(inTown)
        try container.encode(objectID, isLittleEndian: true)
    }
}

