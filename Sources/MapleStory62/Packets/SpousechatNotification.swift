//
//  SpousechatNotification.swift
//
//

import Foundation

public struct SpousechatNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spousechat }

    public let sender: String

    public let message: String

    public init(sender: String, message: String) {
        self.sender = sender
        self.message = message
    }
}

extension SpousechatNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encodeMapleAsciiString(sender)
        try container.encodeMapleAsciiString(message)
    }
}
