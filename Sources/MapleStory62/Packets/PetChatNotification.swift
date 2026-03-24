//
//  PetChatNotification.swift
//
//

import Foundation

public struct PetChatNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .petChat }

    public let characterID: UInt32
    public let slot: UInt8
    public let unknown: UInt16
    public let text: String

    public init(characterID: UInt32, slot: UInt8, unknown: UInt16, text: String) {
        self.characterID = characterID
        self.slot = slot
        self.unknown = unknown
        self.text = text
    }
}

extension PetChatNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(characterID, isLittleEndian: true)
        try container.encode(slot)
        try container.encode(unknown, isLittleEndian: true)
        try container.encodeMapleAsciiString(text)
        try container.encode(UInt8(0))
    }
}

