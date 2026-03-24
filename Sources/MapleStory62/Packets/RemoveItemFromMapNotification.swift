//
//  RemoveItemFromMapNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Notifies clients of a drop being removed from the map
public struct RemoveItemFromMapNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .removeItemFromMap }

    /// Animation type (0 = fade out, 1 = pickup animation, 2 = explode)
    public let animation: UInt8

    /// Object ID of the dropped item to remove
    public let objectID: UInt32

    /// Create remove notification
    public init(animation: UInt8 = 1, objectID: UInt32) {
        self.animation = animation
        self.objectID = objectID
    }
}
