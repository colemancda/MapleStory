//
//  SpawnMistNotification.swift
//
//

import Foundation

public struct SpawnMistNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnMist }

    public let objectID: UInt32
    public let ownerCharacterID: UInt32
    public let skillID: UInt32
    public let level: UInt8
    public let x1: Int32
    public let y1: Int32
    public let x2: Int32
    public let y2: Int32
    public let trailing: UInt32

    public init(
        objectID: UInt32,
        ownerCharacterID: UInt32,
        skillID: UInt32,
        level: UInt8,
        x1: Int32,
        y1: Int32,
        x2: Int32,
        y2: Int32,
        trailing: UInt32 = 0
    ) {
        self.objectID = objectID
        self.ownerCharacterID = ownerCharacterID
        self.skillID = skillID
        self.level = level
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        self.trailing = trailing
    }
}

extension SpawnMistNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(objectID, isLittleEndian: true)
        try container.encode(objectID, isLittleEndian: true) // Java writes object id twice.
        try container.encode(ownerCharacterID, isLittleEndian: true)
        try container.encode(skillID, isLittleEndian: true)
        try container.encode(level)
        try container.encode(UInt16(8), isLittleEndian: true)
        try container.encode(x1, isLittleEndian: true)
        try container.encode(y1, isLittleEndian: true)
        try container.encode(x2, isLittleEndian: true)
        try container.encode(y2, isLittleEndian: true)
        try container.encode(trailing, isLittleEndian: true)
    }
}

