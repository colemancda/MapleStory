//
//  PetCommandNotification.swift
//
//

import Foundation

public struct PetCommandNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .petCommand }

    public let characterID: UInt32
    public let slot: UInt8
    public let isFoodCommand: Bool
    public let command: UInt8
    public let success: Bool

    public init(
        characterID: UInt32,
        slot: UInt8,
        isFoodCommand: Bool,
        command: UInt8,
        success: Bool
    ) {
        self.characterID = characterID
        self.slot = slot
        self.isFoodCommand = isFoodCommand
        self.command = command
        self.success = success
    }
}

extension PetCommandNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(characterID, isLittleEndian: true)
        try container.encode(slot)
        if isFoodCommand == false {
            try container.encode(UInt8(0))
        }
        try container.encode(command)
        try container.encode(success)
        try container.encode(UInt8(0))
    }
}
