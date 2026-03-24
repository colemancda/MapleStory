//
//  UpdatePartyMemberHPNotification.swift
//
//

import Foundation

public struct UpdatePartyMemberHPNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .updatePartyMemberHP }

    public let characterID: UInt32
    public let currentHP: UInt32
    public let maxHP: UInt32

    public init(characterID: UInt32, currentHP: UInt32, maxHP: UInt32) {
        self.characterID = characterID
        self.currentHP = currentHP
        self.maxHP = maxHP
    }
}

extension UpdatePartyMemberHPNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(characterID, isLittleEndian: true)
        try container.encode(currentHP, isLittleEndian: true)
        try container.encode(maxHP, isLittleEndian: true)
    }
}

