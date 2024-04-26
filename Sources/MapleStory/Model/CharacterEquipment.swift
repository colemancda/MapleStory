//
//  CharacterEquipment.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import Collections
import CoreModel

public extension Character {
    
    struct Equipment: Equatable, Hashable, Sendable {
        
        internal typealias Dictionary = OrderedDictionary<Element.Key, Element.Value>
        
        internal var elements: Dictionary
        
        internal init(_ elements: Dictionary) {
            self.elements = elements
        }
        
        public init() {
            self.init([:])
        }
        
        public init(uniqueKeysWithValues elements: [(Element.Key, Element.Value)]) {
            let dictionary = Character.Equipment.Dictionary(uniqueKeysWithValues: elements)
            self.init(dictionary)
        }
    }
}

// MARK: - CustomStringConvertible

extension Character.Equipment: CustomStringConvertible, CustomDebugStringConvertible {
    
    public var description: String {
        elements.description
    }
    
    public var debugDescription: String {
        elements.description
    }
}

// MARK: - ExpressibleByDictionaryLiteral

extension Character.Equipment: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (Element.Key, Element.Value)...) {
        self.init(uniqueKeysWithValues: elements)
    }
}

// MARK: - Codable

extension Character.Equipment: Codable {
    
    public init(from decoder: Decoder) throws {
        self.elements = try Dictionary(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        try elements.encode(to: encoder)
    }
}

// MARK: - AttributeCodable

extension Character.Equipment: AttributeCodable {
    
    public init?(attributeValue: AttributeValue) {
        guard let string = String(attributeValue: attributeValue),
              let value = try? Character.Equipment(decodeJSON: string) else {
            return nil
        }
        self = value
    }
    
    public var attributeValue: AttributeValue {
        try! encodeJSON().attributeValue
    }
}

internal extension Character.Equipment {
    
    static var encoder: JSONEncoder { JSONEncoder() }
    
    static var decoder: JSONDecoder { JSONDecoder() }
    
    init(decodeJSON json: String) throws {
        let elements = try Self.decoder.decode(Dictionary.self, from: Data(json.utf8))
        self.init(elements)
    }
    
    func encodeJSON() throws -> String {
        let data = try Self.encoder.encode(elements)
        return String(data: data, encoding: .utf8)!
    }
}

// MARK: - Collection

extension Character.Equipment: Collection {
    
    public var isEmpty: Bool {
        elements.isEmpty
    }
    
    public var count: Int {
        elements.count
    }
    
    public func makeIterator() -> IndexingIterator<Self> {
        IndexingIterator(_elements: self)
    }
    
    public var startIndex: Int {
        0
    }
    
    public var endIndex: Int {
        count
    }
    
    public func index(after i: Int) -> Int {
       i + 1
    }
    
    public subscript(index: Int) -> Character.Equipment.Element {
        let key = elements.keys[index]
        let value = elements.values[index]
        return .init(key: key, value: value)
    }
    
    public subscript(bounds: Range<Int>) -> Slice<Character.Equipment> {
        Slice(base: self, bounds: bounds)
    }
    
    public subscript(key: Element.Key) -> Element.Value? {
        get { elements[key] }
        set {
            if let newValue {
                elements.updateValue(newValue, forKey: key)
            } else {
                elements.removeValue(forKey: key)
            }
        }
    }
}

// MARK: - Supporting Types

public extension Character.Equipment {
    
    struct Element: Equatable, Hashable, Codable, Sendable {
        
        public typealias Key = UInt8
        
        public typealias Value = UInt32
        
        public let key: Key
        
        public let value: Value
    }
}

// MARK: - Extensions

public extension Dictionary where Key == Character.Equipment.Element.Key, Value == Character.Equipment.Element.Value {
    
    init(_ equipment: Character.Equipment) {
        self.init(uniqueKeysWithValues: equipment.lazy.map { ($0.key, $0.value) })
    }
}
