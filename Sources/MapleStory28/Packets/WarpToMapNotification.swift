//
//  WarpToMapNotification.swift
//
//
//  Created by Alsey Coleman Miller on 5/3/24.
//

import Foundation
import MapleStory
import Collections

public struct WarpToMapNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public typealias CharacterStats = CharacterListResponse.CharacterStats
    
    public static var opcode: ServerOpcode { .channelWarpToMap }
    
    public let channel: UInt32
    
    public let characterPortalCounter: UInt8 // 0
    
    public let isConnecting: Bool // true
    
    public let randomBytesA: UInt32
    
    public let randomBytesB: UInt32
    
    public let randomBytesC: UInt32
    
    public let randomBytesD: UInt32
    
    internal let value0: UInt8 // 0xFF
    
    internal let value1: UInt8 // 0xFF
    
    public let character: Character.Index
    
    public let stats: CharacterStats
    
    public let buddyListSize: UInt8 // 20
    
    public let mesos: UInt32
    
    public let equipSlotSize: UInt8
    
    public let useSlotSize: UInt8
    
    public let setupSlotSize: UInt8
    
    public let etcSlotSize: UInt8
    
    public let cashSlotSize: UInt8
    
    public let equip: Inventory
    
    public let cashEquip: Inventory
    
    public let equipInventory: Inventory
    
    public let useInventory: Inventory
    
    public let setUpInventory: Inventory
    
    public let etcInventory: Inventory
    
    public let cashInventory: Inventory
    
    public let skills: ShortArray<Skill>
    
    public let skillCooldown: ShortArray<Skill.Cooldown>
    
    public let questCount: UInt16
    
    internal let value2: UInt16 // 2029
    
    internal let value3: UInt16
    
    internal let value4: UInt16 // 2000

    internal let value5: UInt16

    internal let value6: UInt16 // 1000

    internal let value7: UInt16

    internal let completedQuestCount: UInt16

    internal let value8: UInt64
    
    internal let value9: UInt64
    
    internal let value10: UInt64
    
    internal let value11: UInt64
    
    internal let value12: UInt64
    
    internal let value13: UInt64
    
    internal let value14: UInt64
    
    public let timestamp: Date
}

public extension WarpToMapNotification {
    
    struct Skill: Codable, Equatable, Hashable, Sendable, Identifiable {
        
        public let id: UInt32
        
        public let level:  UInt32
    }
}

public extension WarpToMapNotification.Skill {
    
    struct Cooldown: Codable, Equatable, Hashable, Sendable, Identifiable {
        
        public let id: UInt32
        
        public let cooldown: UInt16
    }
}

public extension WarpToMapNotification {
    
    /// Array with `UInt16` prefix
    struct ShortArray <Element>: Equatable, Hashable, Codable, Sendable where Element: Equatable, Element: Hashable, Element: Codable, Element: Sendable {
        
        internal var elements: [Element]
    }
}

extension WarpToMapNotification.ShortArray: ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: Element...) {
        self.init(elements: elements)
    }
}

extension WarpToMapNotification.ShortArray: CustomStringConvertible {
    
    public var description: String {
        elements.description
    }
}

extension WarpToMapNotification.ShortArray: MapleStoryCodable {
    
    enum MapleStoryCodingKeys: String, CodingKey {
        case count
        case elements
    }
    
    public init(from container: MapleStoryDecodingContainer) throws {
        let count = try container.decode(UInt16.self, forKey: MapleStoryCodingKeys.count)
        guard count > 0 else {
            self.elements = []
            return
        }
        var elements = [Element]()
        elements.reserveCapacity(Int(count))
        for _ in 0 ..< count {
            let element = try container.decode(Element.self)
            elements.append(element)
        }
        self.elements = elements
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(UInt16(elements.count), forKey: MapleStoryCodingKeys.count)
        try container.encodeArray(elements, forKey: MapleStoryCodingKeys.elements)
    }
}

public extension WarpToMapNotification {
    
    struct Inventory: Codable, Equatable, Hashable, Sendable {
        
        internal var items: OrderedDictionary<UInt8, Item>
        
        public subscript(key: UInt8) -> Item? {
            get { items[key] }
            set { items[key] = newValue }
        }
    }
}

extension WarpToMapNotification.Inventory: ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (UInt8, Item)...) {
        self.items = .init(uniqueKeysWithValues: elements)
    }
}

extension WarpToMapNotification.Inventory: CustomStringConvertible {
    
    public var description: String {
        items.description
    }
}

extension WarpToMapNotification.Inventory: MapleStoryCodable {
    
    enum MapleStoryCodingKeys: CodingKey {
        case id
        case item
        case end
    }
    
    public init(from container: MapleStoryDecodingContainer) throws {
        var items = OrderedDictionary<UInt8, Item>()
        var id = try container.decode(UInt8.self, forKey: MapleStoryCodingKeys.id)
        while id != 0x00 {
            let item = try container.decode(Item.self, forKey: MapleStoryCodingKeys.item)
            items[id] = item
            id = try container.decode(UInt8.self, forKey: MapleStoryCodingKeys.id)
        }
        self.items = items
    }
    
    public func encode(to container: MapleStoryEncodingContainer) throws {
        for (id, item) in items {
            try container.encode(id, forKey: MapleStoryCodingKeys.id)
            try container.encode(item, forKey: MapleStoryCodingKeys.item)
        }
        try container.encode(UInt8(0x00), forKey: MapleStoryCodingKeys.end)
    }
}

public extension WarpToMapNotification.Inventory {
    
    struct Item: Codable, Equatable, Hashable, Sendable {
        
        public let id: UInt32
        
        public var isCash: Bool {
            cashID != nil
        }
        
        public let cashID: UInt64?
        
        public let expireTime: Int64
        
        public let stats: ItemStats
        
        enum CodingKeys: CodingKey {
            case type
            case id
            case isCash
            case expireTime
            case stats
            case cashID
        }
        
        internal init(
            id: UInt32,
            cashID: UInt64? = nil,
            expireTime: Int64,
            stats: WarpToMapNotification.Inventory.Item.ItemStats
        ) {
            self.id = id
            self.expireTime = expireTime
            self.stats = stats
            self.cashID = cashID
        }
        
        public init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<WarpToMapNotification.Inventory.Item.CodingKeys> = try decoder.container(keyedBy: WarpToMapNotification.Inventory.Item.CodingKeys.self)
            
            let type = try container.decode(WarpToMapNotification.Inventory.Item.ItemType.self, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.type)
            self.id = try container.decode(UInt32.self, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.id)
            let isCash = try container.decode(Bool.self, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.isCash)
            if isCash {
                self.cashID = try container.decode(UInt64.self, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.cashID)
            } else {
                self.cashID = nil
            }
            self.expireTime = try container.decode(Int64.self, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.expireTime)
            
            switch type {
            case .a:
                let value = try container.decode(WarpToMapNotification.Inventory.Item.ItemStats.A.self, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.stats)
                self.stats = .a(value)
            case .b:
                let value = try container.decode(WarpToMapNotification.Inventory.Item.ItemStats.B.self, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.stats)
                self.stats = .b(value)
            case .pet:
                let value = try container.decode(WarpToMapNotification.Inventory.Item.ItemStats.Pet.self, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.stats)
                self.stats = .pet(value)
            }
        }
        
        public func encode(to encoder: any Encoder) throws {
            var container: KeyedEncodingContainer<WarpToMapNotification.Inventory.Item.CodingKeys> = encoder.container(keyedBy: WarpToMapNotification.Inventory.Item.CodingKeys.self)
            
            try container.encode(self.stats.type, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.type)
            try container.encode(self.id, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.id)
            try container.encode(self.isCash, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.isCash)
            try container.encodeIfPresent(cashID, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.cashID)
            try container.encode(self.expireTime, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.expireTime)
            
            switch stats {
            case let .a(value):
                try container.encode(value, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.stats)
            case let .b(value):
                try container.encode(value, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.stats)
            case let .pet(value):
                try container.encode(value, forKey: WarpToMapNotification.Inventory.Item.CodingKeys.stats)
            }
        }
    }
}

public extension WarpToMapNotification.Inventory.Item {
    
    enum ItemType: UInt8, Codable, CaseIterable, Sendable {
        
        case a      = 0x01
        case b      = 0x02
        case pet    = 0x03
    }
    
    enum ItemStats: Equatable, Hashable, Codable, Sendable {
        
        case a(A)
        case b(B)
        case pet(Pet)
        
        var type: ItemType {
            switch self {
            case .a: return .a
            case .b: return .b
            case .pet: return .pet
            }
        }
    }
}

public extension WarpToMapNotification.Inventory.Item.ItemStats {
        
    struct A: Equatable, Hashable, Codable, Sendable {
        
        public let upgradeSlots: UInt8
        
        public let scrollLevel: UInt8
        
        public let str: UInt16
        
        public let dex: UInt16
        
        public let int: UInt16
        
        public let luk: UInt16
        
        public let hp: UInt16
        
        public let mp: UInt16
        
        public let watk: UInt16
        
        public let matk: UInt16
        
        public let wdef: UInt16
        
        public let mdef: UInt16
        
        public let accuracy: UInt16
        
        public let avoid: UInt16
        
        public let hands: UInt16
        
        public let speed: UInt16
        
        public let jump: UInt16
        
        public let name: String
        
        public let flag: UInt16
    }
    
    struct B: Equatable, Hashable, Codable, Sendable {
        
        public let amount: UInt16
        
        public let name: String
        
        public let flag: UInt16
        
        //internal var isRechargeableFlag: UInt8
    }
    
    struct Pet: Equatable, Hashable, Codable, Sendable {
        
        public let name: CharacterName
        
        internal let value0: UInt8
        
        internal let value1: UInt16
        
        internal let value2: UInt8
        
        public let expiration: Int64
        
        internal let value3: UInt32
    }
}
