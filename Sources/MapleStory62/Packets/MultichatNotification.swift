//
//  MultichatNotification.swift
//
//

import Foundation

public struct MultichatNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .multichat }

    public let mode: UInt8
    public let name: String
    public let message: String

    public init(mode: UInt8, name: String, message: String) {
        self.mode = mode
        self.name = name
        self.message = message
    }
}

extension MultichatNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(mode)
        try container.encodeMapleAsciiString(name)
        try container.encodeMapleAsciiString(message)
    }
}

