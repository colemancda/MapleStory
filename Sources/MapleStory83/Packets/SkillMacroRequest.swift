//
//  SkillMacroRequest.swift
//

import Foundation

public struct SkillMacroRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .skillMacro }

    public struct Macro: Codable, Equatable, Hashable, Sendable {
        public let name: String
        public let shout: UInt8
        public let skill1: UInt32
        public let skill2: UInt32
        public let skill3: UInt32
    }

    public let macros: [Macro]
}

extension SkillMacroRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        let count = try container.decode(UInt8.self)
        self.macros = try (0 ..< count).map { _ in
            let name = try container.decode(String.self)
            let shout = try container.decode(UInt8.self)
            let s1 = try container.decode(UInt32.self)
            let s2 = try container.decode(UInt32.self)
            let s3 = try container.decode(UInt32.self)
            return Macro(name: name, shout: shout, skill1: s1, skill2: s2, skill3: s3)
        }
    }
}
