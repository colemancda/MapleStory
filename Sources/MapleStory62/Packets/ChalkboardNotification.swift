//
//  ChalkboardNotification.swift
//
//

import Foundation

public enum ChalkboardNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .chalkboard }

    case close(characterID: UInt32)
    case open(characterID: UInt32, message: String)
}

extension ChalkboardNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case .close(let characterID):
            try container.encode(characterID, isLittleEndian: true)
            try container.encode(UInt8(0))
        case .open(let characterID, let message):
            try container.encode(characterID, isLittleEndian: true)
            try container.encode(UInt8(1))
            try container.encodeMapleAsciiString(message)
        }
    }
}

