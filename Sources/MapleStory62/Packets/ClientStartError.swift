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

// MARK: - ExpressibleByStringLiteral

extension ClientStartError: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: StringLiteralType) {
        self.error = value
    }
}
