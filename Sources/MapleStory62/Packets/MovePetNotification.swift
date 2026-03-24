//
//  MovePetNotification.swift
//
//

import Foundation

public struct MovePetNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .movePet }

    public let characterID: UInt32
    public let slot: UInt8
    public let petID: UInt32
    public let movementData: [UInt8]

    public init(characterID: UInt32, slot: UInt8, petID: UInt32, movementData: [UInt8]) {
        self.characterID = characterID
        self.slot = slot
        self.petID = petID
        self.movementData = movementData
    }
}

extension MovePetNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(characterID, isLittleEndian: true)
        try container.encode(slot)
        try container.encode(petID, isLittleEndian: true)
        try container.encode(movementData)
    }
}

