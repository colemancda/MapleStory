//
//  UpdateMountNotification.swift
//
//

import Foundation

public struct UpdateMountNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .updateMount }

    public let characterID: UInt32
    public let level: UInt32
    public let experience: UInt32
    public let tiredness: UInt32
    public let leveledUp: Bool

    public init(
        characterID: UInt32,
        level: UInt32,
        experience: UInt32,
        tiredness: UInt32,
        leveledUp: Bool
    ) {
        self.characterID = characterID
        self.level = level
        self.experience = experience
        self.tiredness = tiredness
        self.leveledUp = leveledUp
    }
}

extension UpdateMountNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(characterID, isLittleEndian: true)
        try container.encode(level, isLittleEndian: true)
        try container.encode(experience, isLittleEndian: true)
        try container.encode(tiredness, isLittleEndian: true)
        try container.encode(leveledUp)
    }
}

