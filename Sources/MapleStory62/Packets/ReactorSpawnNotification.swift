//
//  ReactorSpawnNotification.swift
//
//

import Foundation

public struct ReactorSpawnNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .reactorSpawn }

    public let objectID: UInt32
    public let reactorID: UInt32
    public let state: UInt8
    public let x: Int16
    public let y: Int16

    public init(objectID: UInt32, reactorID: UInt32, state: UInt8, x: Int16, y: Int16) {
        self.objectID = objectID
        self.reactorID = reactorID
        self.state = state
        self.x = x
        self.y = y
    }
}

extension ReactorSpawnNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(objectID, isLittleEndian: true)
        try container.encode(reactorID, isLittleEndian: true)
        try container.encode(state)
        try container.encode(x, isLittleEndian: true)
        try container.encode(y, isLittleEndian: true)
        try container.encode(UInt8(0))
    }
}

