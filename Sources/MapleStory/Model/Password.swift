//
//  Password.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import RegexBuilder

public struct Password: RawRepresentable, Equatable, Hashable, Codable, Sendable {
    
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

internal extension Password {
    
    static let regex = Regex {
        OneOrMore(.word)
        OneOrMore(.digit)
    }
    .asciiOnlyWordCharacters()
    
    static func validate(_ string: String) -> Bool {
        string.wholeMatch(of: self.regex) != nil
    }
}

// MARK: - CustomStringConvertible

extension Password: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue
    }
    
    public var debugDescription: String {
        rawValue
    }
}
