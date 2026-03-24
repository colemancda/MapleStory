//
//  Pet.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import CoreModel

/// Pet ID
public typealias PetID = UInt64

/// Pet data
public struct Pet: Codable, Equatable, Hashable, Identifiable, Sendable {

    public let id: PetID

    /// Pet item ID (what type of pet)
    public let itemID: UInt32

    /// Pet name
    public var name: String

    /// Owner character ID
    public let ownerID: Character.ID

    /// Pet level (1-30)
    public var level: UInt8

    /// Pet closeness (loyalty, 0-1000)
    public var closeness: UInt16

    /// Pet fullness (hunger, 0-100)
    public var fullness: UInt8

    /// Pet expiration date
    public var expiration: Date?

    /// Current position
    public var position: PetPosition?

    /// Is pet spawned/visible
    public var isSpawned: Bool

    public init(
        id: PetID = PetID(UInt64.random(in: 1...1000000)),
        itemID: UInt32,
        name: String,
        ownerID: Character.ID,
        level: UInt8 = 1,
        closeness: UInt16 = 0,
        fullness: UInt8 = 100,
        expiration: Date? = nil,
        position: PetPosition? = nil,
        isSpawned: Bool = false
    ) {
        self.id = id
        self.itemID = itemID
        self.name = name
        self.ownerID = ownerID
        self.level = level
        self.closeness = closeness
        self.fullness = fullness
        self.expiration = expiration
        self.position = position
        self.isSpawned = isSpawned
    }
}

/// Pet position on map
public struct PetPosition: Codable, Equatable, Hashable, Sendable {
    public let x: Int16
    public let y: Int16

    public init(x: Int16, y: Int16) {
        self.x = x
        self.y = y
    }
}

