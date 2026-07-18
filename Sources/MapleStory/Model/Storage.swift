//
//  Storage.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel

/// Character storage inventory
public struct Storage: Codable, Equatable, Hashable, Identifiable, Sendable {

    // MARK: - Properties
    
    public let id: UUID
    
    /// User ID that owns this storage
    public let userID: User.ID

    /// Mesos stored
    public var mesos: UInt32

    /// Number of slots used
    public var slots: UInt8 {
        UInt8(items.count)
    }

    /// Maximum slots (can be expanded)
    public var maxSlots: UInt8

    /// Items in storage (slot -> item)
    public var items: [Int8: InventoryItem]
    
    /// Check if storage has space for more items
    public var hasSpace: Bool {
        return items.count < Int(maxSlots)
    }
    
    /// Check if storage is full
    public var isFull: Bool {
        return items.count >= Int(maxSlots)
    }

    // MARK: - Initialization
    
    public init(
        id: UUID = UUID(),
        userID: User.ID,
        mesos: UInt32 = 0,
        maxSlots: UInt8 = 16,
        items: [Int8: InventoryItem] = [:]
    ) {
        self.id = id
        self.userID = userID
        self.mesos = mesos
        self.maxSlots = maxSlots
        self.items = items
    }
    
    // MARK: - Codable
    
    public enum CodingKeys: String, CodingKey, CaseIterable, Sendable {
        case id
        case userID
        case mesos
        case maxSlots
        case items
    }
}

// MARK: - Entity

extension Storage: Entity {

    public init(from container: ModelData) throws {
        guard container.entity.rawValue == Self.entityName.rawValue else {
            throw CoreModel.CoreModelError.invalidEntity(container.entity)
        }
        guard let id = Self.ID(objectID: container.id) else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Cannot decode identifier from \(container.id)"))
        }
        self.id = id
        self.mesos = try container.decode(UInt32.self, forKey: Storage.CodingKeys.mesos)
        self.maxSlots = try container.decode(UInt8.self, forKey: Storage.CodingKeys.maxSlots)
        self.items = try container.decode([Int8: InventoryItem].self, forKey: Storage.CodingKeys.items)
        self.userID = try container.decodeRelationship(User.ID.self, forKey: Storage.CodingKeys.userID)
    }

    public func encode() -> ModelData {
        var container = ModelData(
            entity: Self.entityName,
            id: ObjectID(self.id)
        )
        container.encode(self.mesos, forKey: Storage.CodingKeys.mesos)
        container.encode(self.maxSlots, forKey: Storage.CodingKeys.maxSlots)
        container.encode(self.items, forKey: Storage.CodingKeys.items)
        container.encodeRelationship(self.userID, forKey: Storage.CodingKeys.userID)
        return container
    }

    public static var attributes: [CodingKeys: AttributeType] {
        [
            .mesos: .int64,
            .maxSlots: .int16,
            .items: .string
        ]
    }
    
    public static var relationships: [CodingKeys: Relationship] {
        [
            .userID: Relationship(
                id: .userID,
                entity: Storage.self,
                destination: User.self,
                type: .toOne,
                inverseRelationship: .storage
            )
        ]
    }
}