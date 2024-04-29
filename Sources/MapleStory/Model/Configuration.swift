//
//  Configuration.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import CoreModel

/// Configuration
public struct Configuration: Equatable, Hashable, Codable, Identifiable, Sendable {
    
    public let id: ID
    
    public var value: String
    
    public init(
        id: ID,
        value: String
    ) {
        self.id = id
        self.value = value
    }
    
    public enum CodingKeys: String, CodingKey {
        case id
        case value
    }
}

// MARK: - Entity

extension Configuration: Entity {
    
    public static var attributes: [CodingKeys: AttributeType] {
        [
            .value: .string
        ]
    }
}

// MARK: - ExpressibleByStringLiteral

extension Configuration.ID: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension Configuration.ID: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue
    }
    
    public var debugDescription: String {
        rawValue
    }
}

// MARK: - Supporting Types

public extension Configuration {
    
    /// Configuration ID
    struct ID: Equatable, Hashable, Codable, RawRepresentable, Sendable {
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

extension Configuration.ID: ObjectIDConvertible {
    
    public init?(objectID: ObjectID) {
        self.init(rawValue: objectID.rawValue)
    }
}

public extension Configuration.ID {
    
    static var lastUserIndex: Configuration.ID {
        "lastUserIndex"
    }
    
    static var pinEnabled: Configuration.ID {
        "pinEnabled"
    }
    
    static var picEnabled: Configuration.ID {
        "picEnabled"
    }
    
    static var autoRegister: Configuration.ID {
        "autoRegister"
    }
}

internal extension Configuration {
    
    var boolValue: Bool? {
        switch value {
        case "0":
            return false
        case "1":
            return true
        default:
            return nil
        }
    }
}

public extension Configuration {
    
    var lastUserID: User.Index? {
        get {
            guard id == .lastUserIndex, let index = User.Index(value) else {
                return nil
            }
            return index
        }
        set {
            guard let newValue, id == .lastUserIndex else {
                return
            }
            value = newValue.description
        }
    }
    
    var isPinEnabled: Bool {
        guard id == .pinEnabled else {
            return false
        }
        return boolValue ?? false
    }
    
    var isPicEnabled: Bool {
        guard id == .picEnabled else {
            return false
        }
        return boolValue ?? false
    }
    
    var isAutoRegisterEnabled: Bool {
        guard id == .autoRegister else {
            return false
        }
        return boolValue ?? true
    }
}
