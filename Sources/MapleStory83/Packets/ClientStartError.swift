//
//  ClientStartError.swift
//
//
//  Created by Alsey Coleman Miller on 5/4/24.
//

import Foundation
import MapleStory

public struct ClientStartError: MapleStoryPacket, Equatable, Hashable, Codable, Sendable {
    
    public static var opcode: ClientOpcode { .clientStartError }
    
    public let error: String
        
    public init(error: String) {
        self.error = error
    }
}

// MARK: - MapleStoryDecodable

extension ClientStartError: MapleStoryDecodable {
    
    public init(from container: MapleStoryDecodingContainer) throws {
        let length = Int(try container.decode(UInt16.self))
        let data = try container.decode(Data.self, length: length)
        if let string = String(data: data, encoding: .ascii) ?? String(data: data, encoding: .isoLatin1) {
            self.error = string
        } else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "Invalid error string"
            ))
        }
    }
}

// MARK: - ExpressibleByStringLiteral

extension ClientStartError: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StringLiteralType) {
        self.error = value
    }
}
