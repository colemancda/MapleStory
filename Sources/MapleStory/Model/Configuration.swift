//
//  Configuration.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import CoreModel

/// Configuration
public struct Configuration: Equatable, Hashable, Sendable {
            
    internal private(set) var elements: [Key: Value]
    
    internal init(_ elements: [Key: Value]) {
        self.elements = elements
    }
    
    internal init(_ elements: [ElementEntity]) {
        self.elements = .init(uniqueKeysWithValues: elements.map { ($0.id, $0.value) })
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension Configuration: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.elements = .init(uniqueKeysWithValues: elements)
    }
}

// MARK: - Sequence

extension Configuration: Sequence {
    
    public typealias Iterator = Dictionary<Key, Value>.Iterator
    
    public func makeIterator() -> Dictionary<Key, Value>.Iterator {
        elements.makeIterator()
    }
}

// MARK: - Collection

extension Configuration: Collection {
    
    /// The element type of a dictionary: a tuple containing an individual key-value pair.
    public typealias Element = (key: Key, value: Value)
    
    /// Index
    public typealias Index = Dictionary<Key, Value>.Index
    
    public var capacity: Int {
        elements.capacity
    }
    
    public var isEmpty: Bool {
        elements.isEmpty
    }
    
    public var count: Int {
        elements.count
    }
    
    public subscript(key: Key) -> Value? {
        get {
            elements[key]
        }
        set {
            elements[key] = newValue
        }
    }
    
    public subscript(position: Index) -> (key: Key, value: Value) {
        elements[position]
    }
    
    public var startIndex: Index {
        elements.startIndex
    }
    
    public var endIndex: Index {
        elements.endIndex
    }
    
    public func index(after index: Index) -> Index {
        elements.index(after: index)
    }
    
    /// Returns the index for the given key.
    public func index(forKey key: Key) -> Index? {
        elements.index(forKey: key)
    }
}

// MARK: - Extensions

public extension ModelStorage {
    
    /// Decode the specified entity from the database file.
    func fetch(
        _ type: Configuration.Type
    ) async throws -> Configuration {
        let elements = try await fetch(Configuration.ElementEntity.self)
        return Configuration(elements)
    }
    
    func fetch(
        configuration key: Configuration.Key
    ) async throws -> Configuration.Value? {
        try await fetch(Configuration.ElementEntity.self, for: key)?.value
    }
    
    func insert(
        _ configuration: Configuration
    ) async throws {
        let values = try configuration.elements.map {
            try Configuration.ElementEntity(id: $0, value: $1).encode()
        }
        try await insert(values)
    }
    
    func insert(
        _ value: Configuration.Value,
        for key: Configuration.Key
    ) async throws {
        let value = Configuration.ElementEntity(id: key, value: value)
        try await insert(value)
    }
    
    func insert(
        _ value: Configuration.Value,
        for key: Configuration.Key,
        in configuration: inout Configuration
    ) async throws {
        try await insert(value, for: key)
        configuration[key] = value
    }
}

public extension Dictionary where Key == Configuration.Key, Value == Configuration.Value {
    
    init(_ configuration: Configuration) {
        self.init()
        self.reserveCapacity(configuration.capacity)
        for (key, value) in configuration {
            self[key] = value
        }
        assert(count == configuration.count)
    }
}

// MARK: - Supporting Types

internal extension Configuration {
    
    /// Configuration
    struct ElementEntity: Equatable, Hashable, Codable, Identifiable, Sendable {
        
        let id: Configuration.Key
        
        var value: Configuration.Value
        
        enum CodingKeys: String, CodingKey {
            case id
            case value
        }
    }
}

extension Configuration.ElementEntity: Entity {
    
    static var entityName: EntityName { "Configuration" }
    
    static var attributes: [CodingKeys: AttributeType] {
        [
            .value: .string
        ]
    }
}

// MARK: - Value

public extension Configuration {
    
    struct Value: RawRepresentable, Equatable, Hashable, Codable, Sendable {
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

// MARK: ExpressibleByStringLiteral

extension Configuration.Value: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

// MARK: ExpressibleByBooleanLiteral

extension Configuration.Value: ExpressibleByBooleanLiteral {
    
    public init(booleanLiteral value: Bool) {
        self.init(bool: value)
    }
}

public extension Configuration.Value {
    
    init(bool value: Bool) {
        self.init(rawValue: value ? "1" : "0")
    }
    
    var boolValue: Bool? {
        switch rawValue {
        case "0":
            return false
        case "1":
            return true
        default:
            return nil
        }
    }
}

// MARK: ExpressibleByIntegerLiteral

extension Configuration.Value: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt32) {
        self.init(integer: value)
    }
}

public extension Configuration.Value {
    
    init(integer value: UInt32) {
        self.init(rawValue: value.description)
    }
    
    var intValue: UInt32? {
        UInt32(rawValue)
    }
}

// MARK: CustomStringConvertible

extension Configuration.Value: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue
    }
    
    public var debugDescription: String {
        rawValue
    }
}

// MARK: - Key

public extension Configuration {
        
    struct Key: RawRepresentable, Equatable, Hashable, Codable, Sendable {
        
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
}

// MARK: ObjectIDConvertible

extension Configuration.Key: ObjectIDConvertible {
    
    public init?(objectID: ObjectID) {
        self.init(rawValue: objectID.rawValue)
    }
}

// MARK: ExpressibleByStringLiteral

extension Configuration.Key: ExpressibleByStringLiteral {
    
    public init(stringLiteral value: String) {
        self.init(rawValue: value)
    }
}

// MARK: CustomStringConvertible

extension Configuration.Key: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        rawValue
    }
    
    public var debugDescription: String {
        rawValue
    }
}

// MARK: Definitions

public extension Configuration.Key {
    
    static var lastUserIndex: Configuration.Key {
        "lastUserIndex"
    }
    
    static var website: Configuration.Key {
        "website"
    }
    
    static var pinEnabled: Configuration.Key {
        "pinEnabled"
    }
    
    static var picEnabled: Configuration.Key {
        "picEnabled"
    }
    
    static var autoRegister: Configuration.Key {
        "autoregister"
    }
    
    static var worldSelection: Configuration.Key {
        "worldSelection"
    }
    
    static var restrictSessionIP: Configuration.Key {
        "restrictSessionIP"
    }
    
    static var loginExpiration: Configuration.Key {
        "loginExpiration"
    }
}

public extension Configuration {
    
    var website: URL? {
        self[.website]
            .flatMap { URL(string: $0.rawValue) }
    }
    
    var lastUserIndex: User.Index? {
        self[.lastUserIndex]?.intValue
    }
    
    var isPinEnabled: Bool? {
        self[.pinEnabled]?.boolValue
    }
    
    var isPicEnabled: Bool? {
        self[.picEnabled]?.boolValue
    }
    
    var isAutoRegisterEnabled: Bool? {
        self[.autoRegister]?.boolValue
    }
    
    var worldSelection: WorldSelectionMode? {
        self[.worldSelection]?.intValue.flatMap { .init(rawValue: $0) }
    }
    
    var restrictSessionIP: Bool? {
        self[.restrictSessionIP]?.boolValue
    }
    
    var loginExpiration: UInt32? {
        self[.loginExpiration]?.intValue
    }
}

public extension Configuration {
    
    static var `default`: Configuration {
        [
            .website: "https://github.com/ColemanCDA/MapleStory",
            .pinEnabled: false,
            .picEnabled: false,
            .autoRegister: true,
            .worldSelection: .init(integer: WorldSelectionMode.skipPrompt.rawValue),
            .restrictSessionIP: true,
            .loginExpiration: 30
        ]
    }
}
