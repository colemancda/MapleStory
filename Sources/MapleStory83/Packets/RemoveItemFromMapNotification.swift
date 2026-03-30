//
//  RemoveItemFromMapNotification.swift
//

import Foundation

/// Removes a dropped item from the map.
///
/// animation: 0 = expire, 1 = silent, 2 = pickup, 4 = explode
public struct RemoveItemFromMapNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .removeItemFromMap }

    /// 0 = expire, 1 = silent/without animation, 2 = pickup, 4 = explode.
    public let animation: UInt8

    public let objectID: UInt32

    /// Present only when animation >= 2.
    public let characterID: UInt32?

    /// Present only when animation >= 2 and picked up by a pet.
    public let petSlot: UInt8?

    public init(animation: UInt8, objectID: UInt32, characterID: UInt32? = nil, petSlot: UInt8? = nil) {
        self.animation = animation
        self.objectID = objectID
        self.characterID = characterID
        self.petSlot = petSlot
    }
}
