//
//  SpawnPortalNotification.swift
//
//

import Foundation

public struct SpawnPortalNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnPortal }

    public let townID: UInt32
    public let targetID: UInt32
    public let positionX: Int16?
    public let positionY: Int16?

    public init(townID: UInt32, targetID: UInt32, positionX: Int16? = nil, positionY: Int16? = nil) {
        precondition((positionX == nil) == (positionY == nil), "Portal position must include both x and y or neither")
        self.townID = townID
        self.targetID = targetID
        self.positionX = positionX
        self.positionY = positionY
    }
}

extension SpawnPortalNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(townID, isLittleEndian: true)
        try container.encode(targetID, isLittleEndian: true)
        if let positionX, let positionY {
            try container.encode(positionX, isLittleEndian: true)
            try container.encode(positionY, isLittleEndian: true)
        }
    }
}

