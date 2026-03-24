//
//  PetNameChangeNotification.swift
//
//

import Foundation

public struct PetNameChangeNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .petNamechange }

    public let characterID: UInt32
    public let newName: String

    public init(characterID: UInt32, newName: String) {
        self.characterID = characterID
        self.newName = newName
    }
}

extension PetNameChangeNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(characterID, isLittleEndian: true)
        try container.encode(UInt8(0))
        try container.encodeMapleAsciiString(newName)
        try container.encode(UInt8(0))
    }
}

