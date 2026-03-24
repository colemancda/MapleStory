//
//  SpawnDoorNotification.swift
//
//

import Foundation

public struct SpawnDoorNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnDoor }

    public let inTown: Bool
    public let objectID: UInt32
    public let x: Int16
    public let y: Int16

    public init(inTown: Bool, objectID: UInt32, x: Int16, y: Int16) {
        self.inTown = inTown
        self.objectID = objectID
        self.x = x
        self.y = y
    }
}

extension SpawnDoorNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(inTown)
        try container.encode(objectID, isLittleEndian: true)
        try container.encode(x, isLittleEndian: true)
        try container.encode(y, isLittleEndian: true)
    }
}

