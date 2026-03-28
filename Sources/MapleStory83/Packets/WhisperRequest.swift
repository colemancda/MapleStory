//
//  WhisperRequest.swift
//

import Foundation

public struct WhisperRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .whisper }

    /// 6 = send whisper, 5 = find player
    public let mode: UInt8

    public let target: String

    /// Message text (send whisper only)
    public let message: String?
}

extension WhisperRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.mode = try container.decode(UInt8.self)
        self.target = try container.decode(String.self)
        if mode == 6 {
            self.message = try container.decode(String.self)
        } else {
            self.message = nil
        }
    }
}
