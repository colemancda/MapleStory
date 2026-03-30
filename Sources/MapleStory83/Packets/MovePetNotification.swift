//
//  MovePetNotification.swift
//

import Foundation

public struct MovePetNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .movePet }

    public let characterID: UInt32

    public let slot: UInt8

    public let petID: UInt32

    public let movements: [Movement]

    public init(characterID: UInt32, slot: UInt8, petID: UInt32, movementData: [Movement]) {
        self.characterID = characterID
        self.slot = slot
        self.petID = petID
        self.movements = movementData
    }
}
