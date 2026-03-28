//
//  DropItemFromMapObjectNotification.swift
//

import Foundation

/// An item or meso drop appears on the map.
///
/// mod: 1 = existing (entering map), 2 = update ownership, 0 = new drop with animation
public struct DropItemFromMapObjectNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .dropItemFromMapobject }

    public let mod: UInt8

    public let objectID: UInt32

    public let isMeso: Bool

    public let itemID: UInt32

    public let ownerID: UInt32

    /// 0=timeout for non-owner, 1=timeout for party, 2=free-for-all, 3=explosive/FFA.
    public let dropType: UInt8

    public let x: Int16

    public let y: Int16

    public let dropperObjectID: UInt32
}
