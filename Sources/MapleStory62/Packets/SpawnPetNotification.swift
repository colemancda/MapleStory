//
//  SpawnPetNotification.swift
//
//

import Foundation

public struct SpawnPetNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .spawnPet }

    public let characterID: UInt32
    public let slot: UInt8
    public let remove: Bool
    public let hunger: Bool
    public let itemID: UInt32?
    public let name: String?
    public let uniqueID: UInt32?
    public let positionX: Int16?
    public let positionY: Int16?
    public let stance: UInt8?
    public let foothold: UInt32?

    public init(
        characterID: UInt32,
        slot: UInt8,
        remove: Bool,
        hunger: Bool = false,
        itemID: UInt32? = nil,
        name: String? = nil,
        uniqueID: UInt32? = nil,
        positionX: Int16? = nil,
        positionY: Int16? = nil,
        stance: UInt8? = nil,
        foothold: UInt32? = nil
    ) {
        self.characterID = characterID
        self.slot = slot
        self.remove = remove
        self.hunger = hunger
        self.itemID = itemID
        self.name = name
        self.uniqueID = uniqueID
        self.positionX = positionX
        self.positionY = positionY
        self.stance = stance
        self.foothold = foothold
    }
}

extension SpawnPetNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(characterID, isLittleEndian: true)
        try container.encode(slot)
        if remove {
            try container.encode(UInt8(0))
            try container.encode(hunger)
        } else {
            guard
                let itemID,
                let name,
                let uniqueID,
                let positionX,
                let positionY,
                let stance,
                let foothold
            else {
                throw EncodingError.invalidValue(
                    self,
                    .init(codingPath: [], debugDescription: "Spawn pet state requires full pet metadata")
                )
            }
            try container.encode(UInt8(1))
            try container.encode(UInt8(0))
            try container.encode(itemID, isLittleEndian: true)
            try container.encodeMapleAsciiString(name)
            try container.encode(uniqueID, isLittleEndian: true)
            try container.encode(UInt32(0), isLittleEndian: true)
            try container.encode(positionX, isLittleEndian: true)
            try container.encode(positionY, isLittleEndian: true)
            try container.encode(stance)
            try container.encode(foothold, isLittleEndian: true)
        }
    }
}

