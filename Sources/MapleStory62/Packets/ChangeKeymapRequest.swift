//
//  ChangeKeymapRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct ChangeKeymapRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .changeKeymap }

    public struct KeyBinding: Equatable, Hashable, Sendable {
        public let key: UInt32
        public let type: UInt8
        public let action: UInt32
    }

    public let bindings: [KeyBinding]
}

extension ChangeKeymapRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        let _ = try container.decode(UInt32.self)
        let count = try container.decode(UInt32.self)
        self.bindings = try (0 ..< count).map { _ in
            let key = try container.decode(UInt32.self)
            let type = try container.decode(UInt8.self)
            let action = try container.decode(UInt32.self)
            return KeyBinding(key: key, type: type, action: action)
        }
    }
}
