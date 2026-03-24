//
//  AriantPqStartNotification.swift
//
//

import Foundation

public enum AriantPqStartNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .ariantPqStart }

    case empty
    case ranking(name: String, score: Int32)
}

extension AriantPqStartNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case .empty:
            try container.encode(UInt8(0))
        case .ranking(let name, let score):
            try container.encode(UInt8(1))
            try container.encodeMapleAsciiString(name)
            try container.encode(score, isLittleEndian: true)
        }
    }
}

