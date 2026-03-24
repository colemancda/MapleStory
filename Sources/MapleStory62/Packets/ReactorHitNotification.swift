//
//  ReactorHitNotification.swift
//
//

import Foundation

public struct ReactorHitNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .reactorHit }

    public let objectID: UInt32
    public let state: UInt8
    public let x: Int16
    public let y: Int16
    public let stance: Int16
    public let frameDelay: UInt8

    public init(objectID: UInt32, state: UInt8, x: Int16, y: Int16, stance: Int16, frameDelay: UInt8 = 5) {
        self.objectID = objectID
        self.state = state
        self.x = x
        self.y = y
        self.stance = stance
        self.frameDelay = frameDelay
    }
}

extension ReactorHitNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(objectID, isLittleEndian: true)
        try container.encode(state)
        try container.encode(x, isLittleEndian: true)
        try container.encode(y, isLittleEndian: true)
        try container.encode(stance, isLittleEndian: true)
        try container.encode(UInt8(0))
        try container.encode(frameDelay)
    }
}

