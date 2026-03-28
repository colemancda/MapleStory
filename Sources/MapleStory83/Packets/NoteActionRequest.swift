//
//  NoteActionRequest.swift
//

import Foundation

public struct NoteActionRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .noteAction }

    public let action: UInt8

    public let noteIDs: [UInt32]
}

extension NoteActionRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.action = try container.decode(UInt8.self)
        let count = try container.decode(UInt8.self)
        let _ = try container.decode(UInt8.self)
        let _ = try container.decode(UInt8.self)
        self.noteIDs = try (0 ..< count).map { _ in
            let id = try container.decode(UInt32.self)
            let _ = try container.decode(UInt8.self)
            return id
        }
    }
}
