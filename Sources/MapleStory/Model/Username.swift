//
//  Username.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import RegexBuilder

public struct Username: RawRepresentable, Equatable, Hashable, Codable, Sendable {
    
    public let rawValue: String
    
    public init?(rawValue: String) {
        guard Self.validate(rawValue) else {
            return nil
        }
        self.init(rawValue)
    }
    
    internal init(_ raw: String) {
        self.rawValue = raw
    }
}

internal extension Username {
    
    static let regex = Regex {
        OneOrMore(.word)
        ZeroOrMore(.digit)
    }
    .asciiOnlyWordCharacters()
    
    static func validate(_ string: String) -> Bool {
        string.wholeMatch(of: self.regex) != nil
    }
}

public extension Username {
    
    func sanitized() -> Username {
        Username(rawValue.lowercased())
    }
}

// MARK: - CustomStringConvertible

extension Username: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue
    }
    
    public var debugDescription: String {
        rawValue
    }
}
